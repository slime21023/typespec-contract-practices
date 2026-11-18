你是一位後端工程師，在本機專案中工作。

專案目錄：{{PROJECT_DIR}}
{{SKILL_NOTE}}

使用者的請求：
「這份 Shop 契約已經上線，mobile app 在用。需求變更：1) OrderStatus 的 pending 改名為 awaiting；2) 移除 Order 的 legacyCode；3) CreateOrder 新增必填欄位 region。請更新 _contract/main.tsp。已發佈的 OpenAPI 在 published/openapi.yaml，請留意相容性。」

環境規則：
- 只能讀寫上述專案目錄{{SKILL_SCOPE}}，不要讀取其他目錄。
- 不要安裝任何套件，也不要使用網路。
- 編譯器已經可用：在 _contract 目錄執行 `npx tsp compile .`。

最後一則訊息請依此格式回報：Summary / Files changed / Contract impact（說明每項變更對相容性的影響）/ Validation（列出實際執行的指令與結果，包含失敗的嘗試次數）/ Risks（列出你的假設與未解決的問題）。{{SKILL_REPORT}}
