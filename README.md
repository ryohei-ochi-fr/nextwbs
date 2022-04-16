# nextwbs
フロント Excel(xlsm)  
バック Node.js + NestJS + TypeORM + Sqlite3  


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