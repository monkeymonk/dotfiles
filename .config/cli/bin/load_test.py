#!/usr/bin/env python3

import argparse
import asyncio
import aiohttp
import time
import statistics


async def fetch(session, url):
    """
    Perform an HTTP GET request and return:
      - the status code
      - the elapsed time for the request
    """
    start_time = time.perf_counter()
    try:
        async with session.get(url) as response:
            _ = await response.text()  # Optionally read the response
            status_code = response.status
    except Exception:
        status_code = 0  # Treat exceptions as failures

    end_time = time.perf_counter()
    return status_code, (end_time - start_time)


async def worker(
    session, url, queue, results, progress_lock, progress_state, total_requests
):
    """
    A worker coroutine that fetches URLs from the queue.
    After each request, it updates and prints the progress.
    """
    while True:
        try:
            _ = queue.get_nowait()  # Grab a 'work item' from the queue
        except asyncio.QueueEmpty:
            break  # No more requests

        status_code, elapsed = await fetch(session, url)
        results.append((status_code, elapsed))

        # Update and print progress
        async with progress_lock:
            progress_state["completed"] += 1
            print(f"Completed {progress_state['completed']} / {total_requests}")


async def load_test(url, total_requests, concurrency):
    queue = asyncio.Queue()

    # Fill the queue with `total_requests` items
    for _ in range(total_requests):
        queue.put_nowait(True)

    results = []

    # We’ll track progress with a shared dictionary
    progress_state = {"completed": 0}
    progress_lock = asyncio.Lock()

    # Limit concurrency using a TCPConnector
    connector = aiohttp.TCPConnector(limit=concurrency)

    async with aiohttp.ClientSession(connector=connector) as session:
        # Create a set of tasks for each "worker"
        tasks = [
            asyncio.create_task(
                worker(
                    session,
                    url,
                    queue,
                    results,
                    progress_lock,
                    progress_state,
                    total_requests,
                )
            )
            for _ in range(concurrency)
        ]

        start_time = time.perf_counter()
        # Wait for all tasks (workers) to complete
        await asyncio.gather(*tasks)
        end_time = time.perf_counter()

    # Analyze results
    total_completed = len(results)
    statuses = [r[0] for r in results]
    response_times = [r[1] for r in results if r[0] != 0]

    success_responses = sum(1 for s in statuses if 200 <= s < 300)
    failures = sum(1 for s in statuses if s == 0 or s >= 400)

    avg_time = statistics.mean(response_times) if response_times else 0.0
    # 95th percentile approximation
    p95_time = 0.0
    if len(response_times) > 1:
        p95_time = statistics.quantiles(response_times, n=100)[94]

    print("\n========== Load Test Results ==========")
    print(f"Target URL              : {url}")
    print(f"Total Requests Attempted: {total_requests}")
    print(f"Total Requests Completed: {total_completed}")
    print(f"Total Time Taken        : {end_time - start_time:.2f} seconds")
    print(f"Successful (2xx)        : {success_responses}")
    print(f"Failures (0 or >=400)   : {failures}")
    print(f"Average Response Time   : {avg_time:.4f} sec")
    print(f"95th Percentile Time    : {p95_time:.4f} sec")
    print("=======================================\n")


def parse_args():
    parser = argparse.ArgumentParser(
        description="A basic async load tester for a single URL with progress output."
    )
    parser.add_argument("--url", required=True, help="The target URL.")
    parser.add_argument(
        "--requests",
        type=int,
        default=100,
        help="Total number of requests to attempt (default: 100).",
    )
    parser.add_argument(
        "--concurrency",
        type=int,
        default=10,
        help="Number of concurrent tasks (default: 10).",
    )
    return parser.parse_args()


def main():
    args = parse_args()
    asyncio.run(load_test(args.url, args.requests, args.concurrency))


if __name__ == "__main__":
    main()
