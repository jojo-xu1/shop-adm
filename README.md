<p align="center">
  <img width="320" src="https://wpimg.wallstcn.com/ecc53a42-d79b-42e2-8852-5126b810a4c8.svg">
</p>

<p align="center">
  <a href="https://github.com/vuejs/vue">
    <img src="https://img.shields.io/badge/vue-2.6.10-brightgreen.svg" alt="vue">
  </a>
  <a href="https://github.com/ElemeFE/element">
    <img src="https://img.shields.io/badge/element--ui-2.7.0-brightgreen.svg" alt="element-ui">
  </a>
  <a href="https://travis-ci.org/PanJiaChen/vue-element-admin" rel="nofollow">
    <img src="https://travis-ci.org/PanJiaChen/vue-element-admin.svg?branch=master" alt="Build Status">
  </a>
  <a href="https://github.com/PanJiaChen/vue-element-admin/blob/master/LICENSE">
    <img src="https://img.shields.io/github/license/mashape/apistatus.svg" alt="license">
  </a>
  <a href="https://github.com/PanJiaChen/vue-element-admin/releases">
    <img src="https://img.shields.io/github/release/PanJiaChen/vue-element-admin.svg" alt="GitHub release">
  </a>
  <a href="https://gitter.im/vue-element-admin/discuss">
    <img src="https://badges.gitter.im/Join%20Chat.svg" alt="gitter">
  </a>
  <a href="https://panjiachen.gitee.io/vue-element-admin-site/zh/donate">
    <img src="https://img.shields.io/badge/%24-donate-ff69b4.svg" alt="donate">
  </a>
</p>

日本語 | [English](./README.md) | [简体中文](./README.zh-CN.md) | [Spanish](./README.es.md)

## 概要

[vue-element-admin](https://panjiachen.github.io/vue-element-admin) は管理画面のフロントエンドのインタフェースで、[vue](https://github.com/vuejs/vue) と [element-ui](https://github.com/ElemeFE/element)を使っています。i18nの多言語対応、可変ルート、権限、典型的なビジネスアプリテンプレートであり、豊富なコンポーネントを提供しています。素早くビジネス用の管理画面の現型を構築に役立ちます。

- [デモページ](https://panjiachen.github.io/vue-element-admin)

- [ドキュメント](https://panjiachen.github.io/vue-element-admin-site/)

- [Gitter](https://gitter.im/vue-element-admin/discuss)

- [Donate](https://panjiachen.gitee.io/vue-element-admin-site/zh/donate)

- [Wiki](https://github.com/PanJiaChen/vue-element-admin/wiki)

- おすすめシンプルテンプレート: [vue-admin-template](https://github.com/PanJiaChen/vue-admin-template)
- デスクトップバージョン: [electron-vue-admin](https://github.com/PanJiaChen/electron-vue-admin)
- Typescriptバージョン: [vue-typescript-admin-template](https://github.com/Armour/vue-typescript-admin-template) (感謝: [@Armour](https://github.com/Armour))
- [awesome-project](https://github.com/PanJiaChen/vue-element-admin/issues/2312)

**バージョン`v4.1.0+`以降について、デフォルトのmasterブランチではi18nをサポートしていません。masterブランチと共にアップデートされる[i18n Branch](https://github.com/PanJiaChen/vue-element-admin/tree/i18n)を使用してください。 **

**現在のバージョン `v4.0+` は `vue-cli` で構築していて、バグ報告は[issue](https://github.com/PanJiaChen/vue-element-admin/issues/new)のissueでお願いします。旧バージョン[tag/3.11.0](https://github.com/PanJiaChen/vue-element-admin/tree/tag/3.11.0)もあります。こちらは`vue-cli`に依存しないです。**

**低いバージョンのブラウザはサーポートしないです(例えば ie)，必要があれば polyfill を追加してください。 [詳細はこちら](https://github.com/PanJiaChen/vue-element-admin/wiki#babel-polyfill)**

## 前準備

ローカル環境に [node](http://nodejs.org/) と [git](https://git-scm.com/)のインストールが必要です。[ES2015+](http://es6.ruanyifeng.com/)、[vue](https://cn.vuejs.org/index.html)、[vuex](https://vuex.vuejs.org/zh-cn/)、[vue-router](https://router.vuejs.org/zh-cn/) 、[vue-cli](https://github.com/vuejs/vue-cli) 、[axios](https://github.com/axios/axios) と [element-ui](https://github.com/ElemeFE/element)で開発しています。Requestは[Mock.js](https://github.com/nuysoft/Mock)のモックデータを使っています。

**バグ修正や新規機能追加のissue と pull requestは大歓迎です。**

[![Edit on CodeSandbox](https://codesandbox.io/static/img/play-codesandbox.svg)](https://codesandbox.io/s/github/PanJiaChen/vue-element-admin/tree/CodeSandbox)

<p align="center">
  <img width="900" src="https://wpimg.wallstcn.com/a5894c1b-f6af-456e-82df-1151da0839bf.png">
</p>

## Sponsors

Become a sponsor and get your logo on our README on GitHub with a link to your site. [[Become a sponsor]](https://www.patreon.com/panjiachen)

<a href="https://flatlogic.com/admin-dashboards?from=vue-element-admin"><img width="150px" src="https://wpimg.wallstcn.com/9c0b719b-5551-4c1e-b776-63994632d94a.png" /></a><p>Admin Dashboard Templates made with Vue, React and Angular.</p>

### GitAds

> vue-element-admin is being sponsored by the following tool; please help to support us by taking a look and signing up to a free trial

[<img src="https://images.gitads.io/vue-element-admin" alt="GitAds" />](https://tracking.gitads.io/?repo=vue-element-admin)

## 機能一覧

```
- ログイン / ログアウト

- Auth認証
  - ページ権限
  - 権限パーミッション
  - 権限設定
  - 外部IDでログイン

- 複数環境デプロイ
  - dev
  - sit
  - stage
  - prod

- 共通機能
  - 多言語切替
  - テーマ切替
  - サイトメニュー（ルートから生成）
  - パンくずリストナビゲーション
  - タブナビゲーション
  - Svg Sprite アイコン
  - ローカル/バックエンド モック データ
  - Screenfull

- WYSIWYG
  - TinyMCE
  - Markdown
  - JSON

- Excel
  - エクスポート
  - インポート
  - リード
  - Zip

- テーブル
  - ダイナミックテーブル
  - ドラッグアンドドロップテーブル
  - インラインエディットテーブル

- エラーページ
  - 401
  - 404

- コンポーネント
  - アバターアップロード
  - トップに戻る
  - ドラッグダイアログ
  - ドラッグ選択
  - ドラッグKanban
  - ドラッグリスト
  - ペインの分割
  - Dropzone
  - スティッキー
  - CountTo

- 高度なサンプル
- エラーログ
- ダッシュボード
- ガイドページ
- ECharts
- クリップボード
- Markdown to html
```

## Getting started

```bash
# clone the project
git clone https://github.com/PanJiaChen/vue-element-admin.git

# enter the project directory
cd vue-element-admin

# install dependency
npm install

# develop
npm run dev
```

http://localhost:9527 が自動的に開きます。

## Build

```bash
# build for test environment
npm run build:stage

# build for production environment
npm run build:prod
```

## Advanced

```bash
# preview the release environment effect
npm run preview

# preview the release environment effect + static resource analysis
npm run preview -- --report

# code format check
npm run lint

# code format check and auto fix
npm run lint -- --fix
```

# xs
