# nextwbs
フロント(入力) Excel(xlsm)  
フロント(表示) html + jQuery + tabulator → いずれは angulerでごにょっと  
バック Node.js + NestJS + TypeORM + Sqlite3(DB)  

れっつすたーと
```
git clone https://github.com/ryohei-ochi-fr/nextwbs.git
cd nextwbs
npm i
cd api
npm start
```

`NextWBS_所属_氏名.xlsm`を適当にリネームして開く、タスク名を入力する


# 以下、作業メモ

nestjs は、グローバルにインストール済み
```
npm i -g @nestjs/cli
```

作業メモ
```powershell
cd nextwbs
nest new api
cd api
npm i

nest g resource tasks
npm i --save @nestjs/typeorm typeorm sqlite3
```

```powershell
vi ormconfig.json
vi api\src\tasks\entities\task.entity.ts
npm run build
npx typeorm migration:generate -d src/database/migrations -n create-tasks
npm run build
npx typeorm migration:run
```

```powershell
npm install class-validator --save
nest g mi middleware/logger
nest g in interceptor/logging
nest g in interceptor/xmlresponse
npm i @nestjs/swagger swagger-ui-express --save
```


```powershell
これいらない？
npm i xml --save
npm i @types/xml --save
npm uninstall @types/xml --save
npm uninstall xml --save



これだけでok？
npm i xmljson --save
npm uninstall xmljson --save


npm i @types/xml2js --save
```


```powershell
nest start --watch
```

# excel

=IFERROR(FILTERXML(WEBSERVICE(CONCATENATE("http://localhost:3000/tasks/",J2,"/",D2,"/",E2,"/",F2,"/",G2,"/",H2,"/",I2)),"//data/status"),"")
=FILTERXML(WEBSERVICE(CONCATENATE("http://",$B$2,":",$B$3,"/api/",$B$4,"/getTaskId/","新規","/",A11)),"//data/id")


# 気象庁天気予報API

[気象庁公式の天気予報API（？）が発見 ～Twitterの開発者界隈に喜びの声が満ちる - やじうまの杜 - 窓の杜](https://forest.watch.impress.co.jp/docs/serial/yajiuma/1309318.html)
