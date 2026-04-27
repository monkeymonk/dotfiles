# AMD GPU / NPU env vars for AI inference on Ryzen AI hardware.
#
# Two things:
#   1. On Strix Point (Ryzen AI 300 series, gfx1150 iGPU), set
#      HSA_OVERRIDE_GFX_VERSION=11.0.0 so ROCm/HIP binaries built for
#      gfx1100 (RDNA 3 dGPUs) run on the 890M/880M iGPU. Only set when
#      ROCm is actually present — pointless to pollute env otherwise.
#   2. Export RUNTIME_AMDGPU_HAS_NPU=1 when /dev/accel/accel0 is exposed
#      by the amdxdna driver, so userspace NPU tools (lemonade-server,
#      ryzen-ai) can branch on it.
#
# Vulkan via RADV needs no env vars on RDNA 3.5. Detection-only — does
# not install or build anything.

runtime_plugin_amdgpu() {
    # Quick gate: any AMD GPU on this box?
    [ -d /sys/class/drm ] || return 0
    grep -qx 0x1002 /sys/class/drm/card*/device/vendor 2>/dev/null || return 0

    # gfx1150 override — only meaningful when ROCm is installed.
    if has_cmd rocminfo || [ -d /opt/rocm ]; then
        if grep -q "AMD Ryzen AI" /proc/cpuinfo 2>/dev/null; then
            export HSA_OVERRIDE_GFX_VERSION="${HSA_OVERRIDE_GFX_VERSION:-11.0.0}"
        fi
    fi

    # NPU presence — amdxdna driver exposes /dev/accel/accel0.
    if [ -e /dev/accel/accel0 ]; then
        export RUNTIME_AMDGPU_HAS_NPU=1
    fi
}

hook_register setup runtime_plugin_amdgpu
