#ALTER TABLE abs_sysmsg ADD sysmsg_user VARCHAR(50);
#ALTER TABLE abs_operation_remind DROP COLUMN prj_stage;

### ネットスーパーTable ###----------
#カテゴリ
DROP TABLE IF EXISTS ns_cat;
CREATE TABLE ns_cat(
    cat_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #カテゴリID
    cat_name		  varchar(50)		NOT NULL,			#カテゴリ名
	  parent_id		  bigint          NOT NULL,		#親カテゴリID、0-Root
    delflg        varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(cat_id)
) DEFAULT CHARSET=utf8;

#商品
DROP TABLE IF EXISTS ns_goods;
CREATE TABLE ns_goods(
    goods_id		bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #商品ID
    goods_name		varchar(50)		NOT NULL,			#商品名
	cat_id		    bigint          NOT NULL,           #カテゴリID
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(goods_id)
) DEFAULT CHARSET=utf8;

#品目
DROP TABLE IF EXISTS ns_item;
CREATE TABLE ns_item(
    item_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #品目ID
    item_name		varchar(50)		NOT NULL,			#品目名
	  goods_id		bigint          NOT NULL,           #商品ID
    item_desp		varchar(200)	,			# 品目紹介文
    price           double          ,           # 本体価格
    taxprice        double          ,           # 税込価格
    itemimg         varchar(50)     ,           # 品目画像Path
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(item_id)
) DEFAULT CHARSET=utf8;

#展示画像
DROP TABLE IF EXISTS ns_catimg;
CREATE TABLE ns_catimg(
    catimg_id		bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #展示画像ID
    catimg_path		varchar(200)	NOT NULL,			#展示画像Path
    catimg_mini		varchar(200)	NOT NULL,			#展示画像のMini版のPath
	cat_id  		bigint          NOT NULL,           #カテゴリID
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(catimg_id)
) DEFAULT CHARSET=utf8;

#展示画像上のラベル位置
DROP TABLE IF EXISTS ns_lbl;
CREATE TABLE ns_lbl(
    lbl_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #ラベルID
    catimg_id		bigint	NOT NULL,			#展示画像ID
    goods_id		bigint	NOT NULL,			#商品ID
	lbl_pst_x  		double  NOT NULL,           #画像上x位置の比率
	lbl_pst_y  		double  NOT NULL,           #画像上y位置の比率
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(lbl_id)
) DEFAULT CHARSET=utf8;

#レシピ
DROP TABLE IF EXISTS ns_rsp;
CREATE TABLE ns_rsp(
    rsp_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #レシピID
    rsp_name		varchar(50)		NOT NULL,			#レシピ名
    rep_desp		varchar(200)	,			# レシピ紹介文
    rsp_img         varchar(50)     ,           # レシピ画像Path
    rsp_metial      varchar(50)     ,           # レシピ材料説明文
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(rsp_id)
) DEFAULT CHARSET=utf8;

#レシピ商品構成
DROP TABLE IF EXISTS ns_rspgoods;
CREATE TABLE ns_rspgoods(
    rgds_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #レシピ商品ID
    goods_id		bigint	NOT NULL,			# 商品ID
    rsp_id		    bigint  NOT NULL,           #レシピID
    rgds_amount		varchar(50)	,			    # 商品用量
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(rgds_id)
) DEFAULT CHARSET=utf8;

#広告
DROP TABLE IF EXISTS ns_cm;
CREATE TABLE ns_cm(
    cm_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #広告ID
    cat_id  		bigint          NOT NULL,   # カテゴリID
    cm_title		varchar(50)	    ,			# 広告タイトル
    cm_img          varchar(50)     ,           # 広告画像Path
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
    createtime		datetime		,			# 新規登録日付時刻
    createuser  	varchar(50)		,			# 新規登録者
    updateuser  	varchar(50)		,			# 更新日付時刻
    updatetime  	datetime		,			# 更新者
	PRIMARY KEY(cm_id)
) DEFAULT CHARSET=utf8;
