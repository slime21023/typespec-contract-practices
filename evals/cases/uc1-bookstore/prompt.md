你是一位後端工程師，在本機專案中工作。

專案目錄：{{PROJECT_DIR}}
{{SKILL_NOTE}}

使用者的請求：
「我們要做一個書店 API 的 TypeSpec 契約。需求：書籍有 isbn（13 位數字）、title、author、price（金額，要精確，不要用浮點數）、publishedDate、status（draft / published / archived）。端點：列出書籍（分頁，每頁最多 100 筆）、取得單一書籍、建立書籍、更新書籍、封存書籍（軟刪除）。所有端點都需要 bearer token。找不到書籍回 404。契約放在 _contract/ 目錄，輸出 OpenAPI 3.0。完成後請告訴我檔案清單與編譯結果。」

環境規則：
- 只能讀寫上述專案目錄{{SKILL_SCOPE}}，不要讀取其他目錄。
- 不要安裝任何套件，也不要使用網路。
- 編譯器已經可用：在 _contract 目錄執行 `npx tsp compile .`，然後檢查產出的 OpenAPI。

最後一則訊息請依此格式回報：Summary / Files changed / Validation（列出實際執行的指令與結果，包含失敗的嘗試次數）/ Risks（列出你的假設與未解決的問題）。{{SKILL_REPORT}}
