# AI/LLM alias registrations.

runtime_ai_aliases() {
    guard_double_load RUNTIME_AI_ALIASES_LOADED || return 0

    alias llm-explain='_llm_explain' --desc "LLM explain" --tags "llm,code"
    alias llm-summary='_llm_summary' --desc "LLM summary" --tags "llm,summary"
    alias llm-arch='_llm_arch' --desc "LLM architecture" --tags "llm,analysis"

    alias llm-review='_llm_review' --desc "LLM review" --tags "llm,git,review"
    alias llm-review-edit='_llm_review_edit' --desc "LLM review edit" --tags "llm,git,review,editor"
    alias llm-commit='_llm_commit' --desc "LLM commit" --tags "llm,git,commit"

    alias llm-cmd='_llm_cmd' --desc "LLM command" --tags "llm,shell"
    alias llm-explain-cmd='_llm_explain_cmd' --desc "LLM explain command" --tags "llm,shell,explain"

    alias llm-refactor='_llm_refactor' --desc "LLM refactor" --tags "llm,refactor"
    alias llm-refactor-edit='_llm_refactor_edit' --desc "LLM refactor edit" --tags "llm,refactor,editor"
    alias llm-optimize='_llm_optimize' --desc "LLM optimize" --tags "llm,optimize"
    alias llm-optimize-edit='_llm_optimize_edit' --desc "LLM optimize edit" --tags "llm,optimize,editor"
    alias llm-security='_llm_security' --desc "LLM security" --tags "llm,security"

    alias llm-test='_llm_test' --desc "LLM test" --tags "llm,test"
    alias llm-test-edit='_llm_test_edit' --desc "LLM test edit" --tags "llm,test,editor"
    alias llm-doc='_llm_doc' --desc "LLM doc" --tags "llm,docs"
    alias llm-doc-edit='_llm_doc_edit' --desc "LLM doc edit" --tags "llm,docs,editor"

    alias llm-debug='_llm_debug' --desc "LLM debug" --tags "llm,debug"
    alias llm-fix='_llm_fix' --desc "LLM fix" --tags "llm,fix"

    alias llm-implement='_llm_implement' --desc "LLM implement" --tags "llm,plan"
    alias llm-convert='_llm_convert' --desc "LLM convert" --tags "llm,convert"
    alias llm-api-client='_llm_api_client' --desc "LLM API client" --tags "llm,api"

    alias llm-code='_llm_code' --desc "LLM code" --tags "llm,interactive"
    alias llm-explain-edit='_llm_explain_edit' --desc "LLM explain edit" --tags "llm,code,editor"

    alias llm-ocr='_llm_ocr' --desc "LLM OCR" --tags "llm,ocr,vision"
    alias llm-vision='_llm_vision' --desc "LLM vision" --tags "llm,vision,image"
    alias llm-embed='_llm_embed' --desc "LLM embed" --tags "llm,embedding"
    alias llm-think='_llm_think' --desc "LLM think" --tags "llm,reasoning"
    alias llm-flash='_llm_flash' --desc "LLM flash" --tags "llm,fast"
    alias llm-flash-file='_llm_flash_file' --desc "LLM flash file" --tags "llm,fast,file"

    alias llm-help='_llm_help' --desc "LLM help" --tags "llm,help"
}
