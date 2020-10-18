<template>
  <div id="items">
    <span>カテゴリ :</span>
    <el-select ref="sel_cat" v-model="cat_id" pla ceholder="カテゴリ名" @change="catChanged">
      <el-option
        v-for="colg in catData"
        :key="colg.cat_id"
        :label="colg.cat_name"
        :value="colg.cat_id"
      />
    </el-select>
    <span>商品 :</span>

    <el-select ref="sel_gds" v-model="goods_id" placeholder="商品名">
      <el-option
        v-for="goods in goodsData"
        :key="goods.goods_id"
        :label="goods.goods_name"
        :value="goods.goods_id"
      />
    </el-select>
    <span>タイムセール :</span>
    <el-select v-model="salesType" placeholder="全て">
      <el-option v-for="slp in saleTypes" :key="slp.value" :label="slp.txt" :value="slp.value" />
    </el-select>
    <br>
    <el-button type="primary" @click="search">检索</el-button>
    <el-button type="info" @click="reset">リセット</el-button>

    <el-table :data="tableData" style="width: 100%">
      <el-table-column label="品目ID" width="75">
        <template slot-scope="scope">
          <span style="margin-left: 10px">{{ scope.row.item_id }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="cat_name" label="カテゴリ名" width="90" />
      <el-table-column prop="goods_name" label="商品名" width="90" />
      <el-table-column label="品目名" width="120">
        <template slot-scope="scope">

          <span style="margin-left: 10px">{{ scope.row.item_name }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="item_desp" label="品目詳細" width="180" />
      <el-table-column prop="price" label="税抜き" width="75" />
      <el-table-column prop="taxprice" label="税込" width="75" />
      <el-table-column prop="sales_rate" label="割引率" width="75" />
      <el-table-column prop="last_price" label="レジ金額" width="75" />
      <el-table-column prop="itemimg" label="画像URL" width="120" />
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button size="mini" @click="itemUpdate(scope.row.item_id)">変更</el-button>
          <el-popconfirm title="削除するか？" @onConfirm="itemDelete(scope.row.item_id)">
            <el-button slot="reference" size="mini" type="danger">删除</el-button>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>
    <div>
      <el-button type="primary" @click="itemInsert">新規登録</el-button>
      <el-dialog :title="title" :close-on-click-modal="false" :visible.sync="visible">
        <el-form ref="form" :model="form" label-width="80px">
          <el-form-item label="カテゴリ" :rules="[{ required: true, message: 'カテゴリを選択ください'}]">
            <el-select v-model="new_cat_id" placeholder="カテゴリ名" @change="newCatChanged">
              <el-option
                v-for="colg in newCatData"
                :key="colg.cat_id"
                :label="colg.cat_name"
                :value="colg.cat_id"
              />
            </el-select>
          </el-form-item>
          <el-form-item label="商品" :rules="[{ required: true, message: '商品類別を選択ください'}]">
            <el-select v-model="new_goods_id" placeholder="商品名">
              <el-option
                v-for="goods in newGoodsData"
                :key="goods.goods_id"
                :label="goods.goods_name"
                :value="goods.goods_id"
              />
            </el-select>&nbsp;
            <el-checkbox v-model="checked" @change="rateShowToggle">タイムセール</el-checkbox>&nbsp;
            <el-input v-show="sale_show" v-model="form.sales_rate" />
          </el-form-item>
          <el-form-item label="品目ID" hidden="true">
            <el-input v-model="form.item_id" />
          </el-form-item>
          <el-form-item label="品目名">
            <el-input v-model="form.item_name" />
          </el-form-item>
          <el-form-item label="税抜き">
            <el-input v-model="form.price" />
          </el-form-item>
          <el-form-item label="税込">
            <el-input v-model="form.taxprice">円</el-input>
          </el-form-item>
          <el-form-item label="画像URL" />
          <el-form-item label="品目詳細">
            <el-input v-model="form.item_desp" type="textarea" />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit(form.item_id)">{{ sub_button }}</el-button>
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
      itemId: '',
      cat_id: '',
      goods_id: '',
      salesType: '',
      sub_button: '',
      sales_rate: '',
      sales_type: '',
      visible: false,
      delVisible: false,
      sale_show: false,
      catData: [],
      goodsData: [],
      tableData: [],
      saleTypes: [
        { txt: 'セール中', value: 1 },
        { txt: '全て', value: 0 }
      ],
      checked: false,
      hidden: true,
      new_cat_id: '',
      new_goods_id: '',
      newCatData: [],
      newGoodsData: [],
      title: '',
      form: {
        delivery: false
      }
    }
  },
  mounted: function() {
    this.getInit()
  },
  methods: {
    itemUpdate: async function(id) {
      this.visible = true
      this.title = '品目更新'
      this.sub_button = '更新'
      this.form = {}
      this.newCatData = this.catData
      this.newGoodsData = this.goodsData

      var req = {
        mode: 'select',
        selectsql:
          'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,gd.goods_id as new_goods_id,gd.cat_id as new_cat_id from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id where im.item_id = ' +
          id +
          " and im.delflg is null or im.delflg = '' and gd.delflg is null"
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then(response => {
          console.log(response.data)
          this.form = response.data.data[0]
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      this.new_cat_id = this.form.cat_id
      this.newCatChanged()
      this.new_goods_id = this.form.goods_id

      this.checked = false
      this.sale_show = true
      console.log(this.hidden)
      if (this.form.sales_type === 1) {
        this.checked = true
        this.sale_show = true
      }
    },
    reset: function() {
      this.cat_id = ''
      this.goodsData = []
      this.goods_id = ''
    },
    rateShowToggle: function() {},
    search: async function() {
      var that = this
      console.log(this.saleTypes)
      if (this.salesType === 0 || this.salesType === '') {
        if (this.goods_id.length === 0 && this.cat_id.length === 0) {
          this.getInit()
        } else if (this.goods_id.length === 0 && this.cat_id !== '') {
          var req1 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type, im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
              "where (im.delflg is null or im.delflg = '') and gd.delflg is null and gd.cat_id =" +
              this.cat_id
          }
          await this.axios
            .post('http://13.112.112.160:8080/test/web.do', req1)
            .then(response => {
              console.log(response.data)
              that.tableData = response.data.data
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else if (this.cat_id !== '' && this.goods_id !== '') {
          var req2 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
              "where (im.delflg is null or im.delflg = '') and gd.delflg is null and im.goods_id =" +
              this.goods_id
          }
          await this.axios
            .post('http://13.112.112.160:8080/test/web.do', req2)
            .then(response => {
              console.log(response.data)
              that.tableData = response.data.data
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else {
          this.tableData = []
        }
      } else {
        if (this.goods_id.length === 0 && this.cat_id.length === 0) {
          var req3 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, ' +
              'im.itemimg as itemimg,gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id ' +
              'left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and im.delflg is null or im.delflg = '' and gd.delflg is null "
          }
          await this.axios
            .post('http://13.112.112.160:8080/test/web.do', req3)
            .then(response => {
              console.log(response.data)
              that.tableData = response.data.data
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
          this._getInit()
        } else if (this.goods_id.length === 0 && this.cat_id !== '') {
          var req4 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and (im.delflg is null or im.delflg = '') and gd.delflg is null and gd.cat_id =" +
              this.cat_id
          }
          await this.axios
            .post('http://13.112.112.160:8080/test/web.do', req4)
            .then(response => {
              console.log(response.data)
              that.tableData = response.data.data
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else if (this.cat_id !== '' && this.goods_id !== '') {
          var req5 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and (im.delflg is null or im.delflg = '') and gd.delflg is null and im.goods_id =" +
              this.goods_id
          }
          await this.axios
            .post('http://13.112.112.160:8080/test/web.do', req5)
            .then(response => {
              console.log(response.data)
              that.tableData = response.data.data
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
          console.log(this.tableData)
        } else {
          this.tableData = []
        }
      }
      for (var item in this.tableData) {
        if (this.tableData[item].sales_type === 0) {
          this.tableData[item].last_price = this.tableData[item].price
        } else {
          this.tableData[item].last_price =
            this.tableData[item].price * this.tableData[item].sales_rate
        }
        console.log(this.tableData[item].last_price)
      }
      console.log(this.tableData)
      // return this.tableData;
    },
    catChanged: async function() {
      this.goods_id = ''
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' +
          this.cat_id
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then(response => {
          console.log(response.data)
          this.goodsData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      return this.goodsData
    },
    newCatChanged: async function() {
      this.new_goods_id = ''
      console.log(this.new_cat_id)
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' +
          this.new_cat_id
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then(response => {
          console.log(response.data)
          this.newGoodsData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.newGoodsData
    },
    itemDelete: async function(id) {
      console.log(id)
      var req = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_item',
        wheresql: 'item_id =' + id,
        data: { delflg: '1' }
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req)
        .then(response => {})
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log(req)
      console.log('delete!')
      this.getInit()
    },
    itemInsert: function() {
      this.visible = true
      this.getInit()
      this.form = {}
      this.newCatData = this.catData
      this.newGoodsData = this.goodsData
      this.new_cat_id = this.cat_id
      this.new_goods_id = this.goods_id
      this.sub_button = '登録'
      this.title = '新規登録'
      this.sale_show = false
    },
    getInit: async function() {
      var req1 = {
        mode: 'select',
        selectsql:
          "select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice, im.itemimg as itemimg,gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.delflg is null or im.delflg = '' and gd.delflg is null"
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req1)
        .then(response => {
          console.log(response.data)
          this.tableData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      for (var item in this.tableData) {
        if (this.tableData[item].sales_type === 0) {
          this.tableData[item].last_price = this.tableData[item].price
        } else {
          this.tableData[item].last_price =
            this.tableData[item].price * this.tableData[item].sales_rate
        }
      }
      console.log(this.tableData)
      this._getInit()
      return this.tableData
    },
    _getInit: async function() {
      var req2 = {
        mode: 'select',
        selectsql: 'select * from ns_cat where delflg is null '
      }
      await this.axios
        .post('http://13.112.112.160:8080/test/web.do', req2)
        .then(response => {
          console.log(response.data)
          this.catData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.catData
    },
    onSubmit: async function(id) {
      this.visible = false
      if (this.checked) {
        this.sales_type = 1
        this.sales_rate = this.form.sales_rate
      } else {
        this.sales_type = 0
        this.sales_rate = null
      }
      if (id) {
        var req = {
          rscode: 'ok',
          mode: 'update',
          tableName: 'ns_item',
          wheresql: 'item_id =' + id,
          data: {
            item_name: this.form.item_name,
            goods_id: this.new_goods_id,
            item_desp: this.form.item_desp,
            sales_rate: this.sales_rate,
            sales_type: this.sales_type,
            price: this.form.price,
            taxprice: this.form.taxprice,
            itemimg: this.form.itemimg
          }
        }
        console.log(req)
        await this.axios
          .post('http://13.112.112.160:8080/test/web.do', req)
          .then(response => {})
          .catch(response => {
            console.log('Homepage getGoodsRsp  error!' + response)
          })
        console.log('update!')
      } else {
        var req2 = {
          mode: 'insert',
          tableName: 'ns_item',
          data: {
            item_name: this.form.item_name,
            goods_id: this.new_goods_id,
            item_desp: this.form.item_desp,
            sales_rate: this.sales_rate,
            sales_type: this.sales_type,
            price: this.form.price,
            taxprice: this.form.taxprice,
            itemimg: this.form.itemimg
          }
        }

        await this.axios
          .post('http://13.112.112.160:8080/test/web.do', req2)
          .then(response => {
            console.log(response.data)
          })
          .catch(response => {
            console.log('Homepage getGoodsRsp  error!' + response)
          })
      }
      console.log('submit!')
      this.search()
      this.sales_rate = ''
      this.sales_type = ''
    }
  }
}
</script>
