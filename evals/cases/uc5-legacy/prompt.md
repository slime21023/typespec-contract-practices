你是一位後端工程師，在本機專案中工作。

專案目錄：{{PROJECT_DIR}}
{{SKILL_NOTE}}

使用者的請求：
「我們的訂單 API 目前的 TypeSpec 在 src/api/orders.tsp。請幫我新增 GET /orders/{orderId}/history，回傳該訂單的狀態變更紀錄（每筆有 status 與 changedAt 時間）。」

環境規則：
- 只能讀寫上述專案目錄{{SKILL_SCOPE}}，不要讀取其他目錄。
- 不要安裝任何套件，也不要使用網路。
- 編譯器已經可用：在專案根目錄執行 `npx tsp compile .`（依 tspconfig.yaml 輸出）。

最後一則訊息請依此格式回報：Summary / Files changed / Validation（列出實際執行的指令與結果，包含失敗的嘗試次數）/ Risks（列出你的假設與未解決的問題）。{{SKILL_REPORT}}
