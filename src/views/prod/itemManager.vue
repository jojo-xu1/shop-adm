<template>
  <div id="items">
    <span>カテゴリ :</span>
    <el-select v-model="cat_id" placeholder="カテゴリ名" @change="catChanged">
      <el-option
        v-for="colg in catData"
        :key="colg.cat_id"
        :label="colg.cat_name"
        :value="colg.cat_id"
      />
    </el-select>
    <span>商品 :</span>
    <el-select v-model="goods_id" placeholder="商品名" @change="goodsChanged">
      <el-option
        v-for="goods in goodsData"
        :key="goods.goods_id"
        :label="goods.goods_name"
        :value="goods.goods_id"
      />
    </el-select>
    <br>
    <el-button type="primary" @click="search">检索</el-button>
    <el-button type="info">リセット</el-button>

    <el-table :data="tableData" style="width: 100%">
      <el-table-column label="品目ID" width="120">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span style="margin-left: 10px">{{ scope.row.item_id }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="cat_name" label="カテゴリ名" width="120" />
      <el-table-column prop="goods_name" label="商品名" width="120" />
      <el-table-column label="品目名" width="180">
        <template slot-scope="scope">
          <i class="el-icon-time" />
          <span style="margin-left: 10px">{{ scope.row.item_name }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="item_desp" label="品目詳細" width="180" />
      <el-table-column prop="price" label="税抜き" width="120" />
      <el-table-column prop="taxprice" label="税込" width="120" />
      <el-table-column prop="itemimg" label="画像URL" width="120" />
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button
            size="mini"
            @click="itemUpdate(scope.item_id)"
          >変更</el-button>
          <!-- <el-popover placement="top" width="160" v-model="visible">
            <p>这是一段内容这是一段内容确定删除吗？</p>
            <div style="text-align: right; margin: 0">
              <el-button size="mini" type="text" @click="visible = false">取消</el-button>
              <el-button type="primary" size="mini" @click="visible = false">确定</el-button>
            </div>
            <el-button slot="reference" >删除</el-button>
          </el-popover>-->
          <el-button
            size="mini"
            type="danger"
            @click="itemDelete(scope.row.item_id, scope.row.item_name)"
          >削除</el-button>
        </template>
      </el-table-column>
    </el-table>
    <div>
      <el-button type="primary" @click="itemInsert">新規登録</el-button>

      <el-dialog
        :title="title"
        :close-on-click-modal="false"
        :visible.sync="visible"
      >
        <el-form ref="form" :model="form" label-width="80px">
          <el-form-item label="品目名">
            <el-input v-model="form.name" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit">登録</el-button>
            <el-button @click="visible = false">キャンセル</el-button>
          </el-form-item>
        </el-form>
      </el-dialog>

    </div>
  </div>
</template>

<script>
export default {
  name: 'ItemManager',
  data() {
    return {
      catId: '',
      goodsId: '',
      itemId: '',
      cat_id: '',
      goods_id: '',
      visible: false,
      catData: [],
      goodsData: [],
      tableData: [],
      title: '新規登録',
      form: {
        delivery: false
      }
    }
  },
  mounted: function() {
    this.getInit()
  },
  methods: {
    itemUpdate: function(id) {
      alert(id)
    },
    search: async function() {
      var req = {
        mode: 'select',
        selectsql:
          'select im.item_id as item_id,im.item_name as item_name,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,' +
          'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
          "where (im.delflg is null or im.delflg = '') and gd.delflg is null and im.goods_id =" +
          this.goodsId
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then((response) => {
          console.log(response.data)
          this.tableData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.tableData
    },
    catChanged: async function(value) {
      console.log(value)
      this.catId = value
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' + value
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then((response) => {
          console.log(response.data)
          this.goodsData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.goodsData
    },
    goodsChanged: function(value) {
      console.log(value)
      this.goodsId = value
    },
    async itemDelete(id, name) {
      alert('品目「' + id + name + '」削除する？')
      var req = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_item',
        wheresql: 'item_id =' + id,
        data: { delflg: 1 }
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then((response) => {})
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log(req)
      console.log('delete!')
      this.getInit()
    },
    itemInsert: async function() {
      this.visible = true
      this.getInit()
    },
    getInit: async function() {
      var req1 = {
        mode: 'select',
        selectsql:
          "select im.item_id as item_id,im.item_name as item_name,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.delflg is null or im.delflg = '' and gd.delflg is null"
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req1)
        .then((response) => {
          console.log(response.data)
          this.tableData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      this._getInit()
      return this.tableData
    },
    _getInit: async function() {
      var req2 = {
        mode: 'select',
        selectsql: 'select * from ns_cat where delflg is null '
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req2)
        .then((response) => {
          console.log(response.data)
          this.catData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.catData
    },
    async onSubmit() {
      this.visible = false
      var req = {
        mode: 'insert',
        tableName: 'ns_item',
        data: {
          item_name: this.form.name,
          goods_id: this.goodsId,
          item_desp: this.form.desc,
          price: this.form.price,
          taxprice: this.form.tax,
          itemimg: this.form.path
        }
      }
      await this.$axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then((response) => {
          console.log(response.data)
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log(req)
      console.log('submit!')
      this.getInit()
    }
  }
}
</script>
