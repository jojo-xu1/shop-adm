#ALTER TABLE abs_sysmsg ADD sysmsg_user VARCHAR(50);
#ALTER TABLE abs_operation_remind DROP COLUMN prj_stage;

### ネットスーパーTable ###----------
#カテゴリ
DROP TABLE IF EXISTS ns_cat;
CREATE TABLE ns_cat(
    cat_id		    bigint UNSIGNED AUTO_INCREMENT NOT NULL,   #カテゴリID
    cat_name		varchar(50)		NOT NULL,			#カテゴリ名
	parent_id		bigint,				                #親カテゴリID
    delflg          varchar(1)      ,           # 削除フラグ　'1' - 削除
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
