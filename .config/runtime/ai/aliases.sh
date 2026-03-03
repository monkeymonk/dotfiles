# AI/LLM alias registrations via alx.

runtime_ai_aliases() {
    [ "${RUNTIME_AI_ALIASES_LOADED-}" = "1" ] && return 0
    RUNTIME_AI_ALIASES_LOADED=1

    runtime_alias llm-explain '_llm_explain' --desc "LLM explain" --tags "llm,code"
    runtime_alias llm-summary '_llm_summary' --desc "LLM summary" --tags "llm,summary"
    runtime_alias llm-arch '_llm_arch' --desc "LLM architecture" --tags "llm,analysis"

    runtime_alias llm-review '_llm_review' --desc "LLM review" --tags "llm,git,review"
    runtime_alias llm-review-edit '_llm_review_edit' --desc "LLM review edit" --tags "llm,git,review,editor"
    runtime_alias llm-commit '_llm_commit' --desc "LLM commit" --tags "llm,git,commit"

    runtime_alias llm-cmd '_llm_cmd' --desc "LLM command" --tags "llm,shell"
    runtime_alias llm-explain-cmd '_llm_explain_cmd' --desc "LLM explain command" --tags "llm,shell,explain"

    runtime_alias llm-refactor '_llm_refactor' --desc "LLM refactor" --tags "llm,refactor"
    runtime_alias llm-refactor-edit '_llm_refactor_edit' --desc "LLM refactor edit" --tags "llm,refactor,editor"
    runtime_alias llm-optimize '_llm_optimize' --desc "LLM optimize" --tags "llm,optimize"
    runtime_alias llm-optimize-edit '_llm_optimize_edit' --desc "LLM optimize edit" --tags "llm,optimize,editor"
    runtime_alias llm-security '_llm_security' --desc "LLM security" --tags "llm,security"

    runtime_alias llm-test '_llm_test' --desc "LLM test" --tags "llm,test"
    runtime_alias llm-test-edit '_llm_test_edit' --desc "LLM test edit" --tags "llm,test,editor"
    runtime_alias llm-doc '_llm_doc' --desc "LLM doc" --tags "llm,docs"
    runtime_alias llm-doc-edit '_llm_doc_edit' --desc "LLM doc edit" --tags "llm,docs,editor"

    runtime_alias llm-debug '_llm_debug' --desc "LLM debug" --tags "llm,debug"
    runtime_alias llm-fix '_llm_fix' --desc "LLM fix" --tags "llm,fix"

    runtime_alias llm-implement '_llm_implement' --desc "LLM implement" --tags "llm,plan"
    runtime_alias llm-convert '_llm_convert' --desc "LLM convert" --tags "llm,convert"
    runtime_alias llm-api-client '_llm_api_client' --desc "LLM API client" --tags "llm,api"

    runtime_alias llm-code '_llm_code' --desc "LLM code" --tags "llm,interactive"
    runtime_alias llm-explain-edit '_llm_explain_edit' --desc "LLM explain edit" --tags "llm,code,editor"

    runtime_alias llm-ocr '_llm_ocr' --desc "LLM OCR" --tags "llm,ocr,vision"
    runtime_alias llm-vision '_llm_vision' --desc "LLM vision" --tags "llm,vision,image"
    runtime_alias llm-embed '_llm_embed' --desc "LLM embed" --tags "llm,embedding"
    runtime_alias llm-think '_llm_think' --desc "LLM think" --tags "llm,reasoning"
    runtime_alias llm-flash '_llm_flash' --desc "LLM flash" --tags "llm,fast"
    runtime_alias llm-flash-file '_llm_flash_file' --desc "LLM flash file" --tags "llm,fast,file"

    runtime_alias llm-help '_llm_help' --desc "LLM help" --tags "llm,help"
}
