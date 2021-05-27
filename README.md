# MachinistとCloudRunをつなげてみる
- nginx access.logのStatus Code別のカウントおよびレートをお手軽に描画して表示させるまでを詳解
- 参考画像 -> https://github.com/isfukuda/Machinist_CloudRun/blob/main/machinist.png
## 使うもの一覧
* [IIJ Machinist](https://machinist.iij.jp/#/)
* [CloudRun](https://cloud.google.com/run)
* [nginx](https://www.nginx.co.jp/blog/deploying-nginx-nginx-plus-docker/)
* [fluentd](https://www.fluentd.org/architecture)
* [fluent-plugin-datacounter](https://github.com/tagomoris/fluent-plugin-datacounter)
* [fluent-plugin-machinist](https://github.com/iij/fluent-plugin-machinist)
## SignUP, Google Cloud Platform and IIJ Machinist 
* https://cloud.google.com/free/?hl=ja 
* https://app.machinist.iij.jp/sign-up
## Install, setup
* [fluentd install](https://docs.fluentd.org/installation)
* Machinistの利用方法は[こちら](https://machinist.iij.jp/getting-started/)
* 参考: [Nginxのログをdatacounterで集計する方法](https://qiita.com/snagasawa_/items/a2d7ff9d21d535f1f8bb)
* [gcloud cli](https://cloud.google.com/sdk?hl=JA)を使えるようしておく
## CloudRunでMachinistのチャートを表示させる
* やることは大きく２つ
  ```
  1.nginxを機動、アクセスログを集計、Machinistへ投げ込む
  2.Serverlessコンテナ基盤であるCloudRunへ軽量nginxコンテナをデプロイ
  ```
### 0.仕込み
* nginx access.logをDatacounter Pluginで集計する
* Machinistでデータを受け取る為のAPI key発行をしておく
* fluent-plugin-machinist経由でデータを投げ込む
* Machinistでチャートを作り、画面共有する設定すませる
### 1.コンテナ作成準備
* gcloudコマンドが使える環境へ各種ファイルを取得する
  ```
  $ git clone https://github.com/isfukuda/Machinist_CloudRun.git
  $ cd Machinist_CloudRun
  $ ls 
  Dokcerfile README nginx/ html/
  ```
### 2.Machinistコンソールで情報取得
* [こちらに](https://machinist.iij.jp/getting-started/getting_started/custom_chart.html)従い「チャートの共有」で**埋め込みコード**を確認する
### 3.表示コンテンツ修正 
* index.htmlを編集し、Machinistから得た**埋め込みコード**を加える
  ```
  $ ls 
  Dokcerfile README nginx/ html/
  $ vi html/index.html
  e.g
   <h1>Count Data from Machinist</h1>
   <iframe src="https://app.machinist.iij.jp/embed/chart/XXXXXXXXXX?toolbar=false&legend=true&datatable=false&theme=Light&type=lineChart&period=raw&to=&reload=true" frameborder="0" scrolling="no" width="800px" height="300px"></iframe>
  $ 
  ```
### 4.カスタムコンテナ作り / build,push amd run
* build実行、STSTUS/SUCCESSで終わる事!
  ```
  $ gcloud builds submit --tag gcr.io/<YOUR Project ID>/machinist
   ```
* CloudRun実行
  ```
  $ gcloud beta run deploy --image gcr.io/XXXXXX/machinist
  Please choose a target platform:
   [1] Cloud Run (fully managed)
   [2] Cloud Run for Anthos deployed on Google Cloud
   [3] Cloud Run for Anthos deployed on VMware
   [4] cancel
  Please enter your numeric choice:  1
  ....
  Please enter your numeric choice:  3

  To make this the default region, run `gcloud config set run/region asia-northeast1`.
  
  Deploying container to Cloud Run service [machinist] in project [XXXXXXX] region [asia-northeast1]
  ✓ Deploying... Done.                                                           
  ✓ Creating Revision...                                                       
  ✓ Routing traffic...                                                         
  Done.                                                                          
  Service [machinist] revision [machinist-00003-wol] has been deployed and is serving 100 percent of traffic.
  Service URL: Please enter your numeric choice:  3
  
  To make this the default region, run `gcloud config set run/region asia-northeast1`.
  
  Deploying container to Cloud Run service [machinist] in project [XXXXXXXX] region [asia-northeast1]  
  ✓ Deploying... Done.                                                           
  ✓ Creating Revision...                                                       
  ✓ Routing traffic...                                                         
  Done.                                                                          
  Service [machinist] revision [machinist-00003-wol] has been deployed and is serving 100 percent of traffic.
  Service URL: https://machinist-XXXXXXX-an.a.run.app
  ```
### 5.確認
* 意図したチャートが表示されれば終了、おつかれ様でした
 ```
 $ curl https://machinist-XXXXXXX-an.a.run.app
   ```
