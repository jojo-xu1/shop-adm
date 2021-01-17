<template>
  <div id="items">
    <span>カテゴリ :</span>
    <el-cascader
      ref="myCascader"
      :props="fatherCatData"
      placeholder="カテゴリ"
      @change="catChanged"
    />

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
      <el-option
        v-for="slp in saleTypes"
        :key="slp.value"
        :label="slp.txt"
        :value="slp.value"
      />
    </el-select>
    <br>
    <el-button type="primary" @click="search">检索</el-button>
    <el-button type="info" @click="reset">リセット</el-button>
    <el-button type="primary" @click="itemInsert">新規登録</el-button>
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
      <el-table-column prop="price" label="税抜き(円)" width="125" />
      <el-table-column prop="taxprice" label="税込(円)" width="75" />
      <el-table-column prop="sales_rate" label="割引率" width="75" />
      <el-table-column prop="last_price" label="レジ金額(円)" width="125" />
      <el-table-column prop="unit" label="単位" width="50" />
      <el-table-column prop="itemimg" label="画像URL" width="120" />
      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button
            size="mini"
            @click="itemUpdate(scope.row.item_id)"
          >変更</el-button>
          <el-popconfirm
            title="削除するか？"
            @onConfirm="itemDelete(scope.row.item_id)"
          >
            <el-button
              slot="reference"
              size="mini"
              type="danger"
            >删除</el-button>
          </el-popconfirm>
        </template>
      </el-table-column>
    </el-table>
    <div>
      <el-dialog
        :title="title"
        :close-on-click-modal="false"
        :visible.sync="visible"
        @close="insertCencle()"
      >
        <el-form ref="form" :model="form" label-width="80px">
          <el-form-item label="カテゴリ" prop="cat">
            <el-input
              v-show="itemupdate"
              v-model="form.cat_name"
              :disabled="true"
            />
            <el-cascader
              v-show="iteminsert"
              ref="myCascader2"
              :props="fatherCatData"
              placeholder="カテゴリ"
              @change="newCatChanged"
            />
          </el-form-item>
          <el-form-item label="商品" prop="goods">
            <el-input
              v-show="itemupdate"
              v-model="form.goods_name"
              :disabled="true"
            />
            <el-input v-show="false" v-model="form.goods_id" :disabled="true" />
            <el-select
              v-show="iteminsert"
              v-model="new_goods_id"
              placeholder="商品名"
            >
              <el-option
                v-for="goods in newGoodsData"
                :key="goods.goods_id"
                :label="goods.goods_name"
                :value="goods.goods_id"
              /> </el-select>&nbsp;
            <el-checkbox
              v-model="checked"
              @change="rateShowToggle"
            >タイムセール</el-checkbox>&nbsp;
            <el-input
              v-show="sale_show"
              v-model="form.sales_rate"
              placeholder="セール率"
            />
          </el-form-item>
          <el-form-item label="品目ID" hidden="true">
            <el-input v-model="form.item_id" />
          </el-form-item>
          <el-form-item label="品目名" prop="item">
            <el-input v-model="form.item_name" />
          </el-form-item>
          <el-form-item label="税抜き" prop="price">
            <el-input
              v-model="form.price"
              @input="
                form.price = form.price.replace(/[^0-9+^\uFF10-\uFF19]+/g, '')
              "
            />
          </el-form-item>
          <el-form-item label="税込" prop="taxprice">
            <el-input
              v-model="form.taxprice"
              @input="
                form.taxprice = form.taxprice.replace(
                  /[^0-9+^\uFF10-\uFF19]+/g,
                  ''
                )
              "
            />
          </el-form-item>
          <el-form-item label="単位" prop="unit">
            <el-input v-model="form.unit" />
          </el-form-item>
          <el-form-item label="品目詳細">
            <el-input v-model="form.item_desp" prop="textarea" />
          </el-form-item>
          <el-form-item label="画像URL">
            <el-input v-if="pathHide" v-model="form.itemimg" />
            <div class="file_box">
              <span class="upload">
                <input
                  id="imgUpload"
                  type="file"
                  value="画像選択"
                  accept="image/*"
                  @change="tirggerFile($event)"
                >

                <img :src="form.itemimg" alt>
              </span>
            </div>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit(form.item_id)">{{
              sub_button
            }}</el-button>
            <el-button @click="insertCencle()">キャンセル</el-button>
          </el-form-item>
        </el-form>
      </el-dialog>
    </div>
  </div>
</template>

<script>
import axios from 'axios'
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
      itemupdate: false,
      iteminsert: true,
      visible: false,
      delVisible: false,
      sale_show: false,
      formParam: '',
      catData: [],
      fatherCatData: {
        lazy: true,
        lazyLoad(node, resolve) {
          var req = {}
          if (node.level === 0) {
            req = {
              mode: 'select',
              selectsql:
                "select cat_id,cat_name,leaf_flag from ns_cat where parent_id = '0' and delflg is null "
            }
          } else {
            req = {
              mode: 'select',
              selectsql:
                'select cat_id,cat_name,leaf_flag from ns_cat where parent_id = ' +
                node.data.value
            }
          }
          console.log(req)
          var baseUrl = process.env.NODE_ENV === 'production' ? 'http://13.112.112.160:9080/test' : 'http://13.112.112.160:8080/test'
          axios
            .post(baseUrl + '/web.do', req)
            .then(res => {
              const cities = res.data.data.map(value => ({
                value: value.cat_id,
                label: value.cat_name,
                leaf: value.leaf_flag === 1
              }))
              // 通过调用resolve将子节点数据返回，通知组件数据加载完成
              resolve(cities)
            })
            .catch((err) => {
              console.log(err)
            })
        }
      },
      goodsData: [],
      tableData: [],
      newTableData: [],
      pathHide: false,
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
    if (this.$route.params.goods_id === undefined) {
      this.getInit()
    } else {
      this.routeSearch()
    }
  },
  methods: {
    async routeSearch() {
      var that = this
      var req1 = {
        mode: 'select',
        selectsql:
          'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type, im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit,im.itemimg as itemimg,' +
          'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
          "where (im.delflg is null or im.delflg = '') and gd.delflg is null and gd.goods_id =" +
          // this.cat_id,
          this.$route.params.goods_id
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req1)
        .then((response) => {
          console.log(response.data)
          that.newTableData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      this.tableData = this.newTableData
      console.log('tableData--------' + this.tableData)
      // レジ金額再計算
      for (var item in this.tableData) {
        if (this.tableData[item].sales_type === 0) {
          this.tableData[item].last_price = this.tableData[item].taxprice
        } else {
          var temp =
            this.tableData[item].taxprice * this.tableData[item].sales_rate
          var temp1 = temp.toString().indexOf('.')
          if (temp1 > 0) {
            this.tableData[item].last_price = temp
              .toString()
              .substring(0, temp1)
          } else {
            this.tableData[item].last_price = temp
          }
        }
      }
      return this.tableData
    },
    // 更新ボタン押下
    itemUpdate: async function(id) {
      this.visible = true
      this.itemupdate = true
      this.iteminsert = false
      this.title = '品目更新'
      this.sub_button = '更新'
      this.form = {}
      var req = {
        mode: 'select',
        selectsql:
          'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, im.itemimg as itemimg,gd.goods_id as goods_id,gd.goods_name as goods_name,cat.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat cat on gd.cat_id = cat.cat_id where im.item_id = ' +
          id +
          " and im.delflg is null or im.delflg = '' and gd.delflg is null"
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then((response) => {
          console.log(response.data)
          this.form = response.data.data[0]
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      if (this.form.itemimg) {
        this.pathHide = true
      }
      this.checked = false
      this.sale_show = false
      if (this.form.sales_type === 1) {
        this.checked = true
        this.sale_show = true
      }
    },
    // 選択条件リセット
    reset: function() {
      this.$refs['myCascader'].$refs.panel.clearCheckedNodes()
      this.cat_id = ''
      this.goodsData = []
      this.goods_id = ''
    },
    // セール率表示
    rateShowToggle: function() {
      if (this.checked) {
        this.sale_show = true
      } else {
        this.sale_show = false
      }
    },
    // 品目検索
    search: async function() {
      var that = this
      if (this.salesType === 0 || this.salesType === '') {
        if (this.goods_id.length === 0 && this.cat_id.length === 0) {
          this.getInit()
        } else if (this.goods_id.length === 0 && this.cat_id !== '') {
          var req1 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type, im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit,im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
              "where (im.delflg is null or im.delflg = '') and gd.delflg is null and gd.cat_id =" +
              this.cat_id
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req1)
            .then((response) => {
              console.log(response.data)
              that.newTableData = response.data.data
            })
            .catch((response) => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else if (this.cat_id !== '' && this.goods_id !== '') {
          var req2 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id ' +
              "where (im.delflg is null or im.delflg = '') and gd.delflg is null and im.goods_id =" +
              this.goods_id
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req2)
            .then((response) => {
              console.log(response.data)
              that.newTableData = response.data.data
            })
            .catch((response) => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else {
          this.newTableData = []
        }
      } else {
        if (this.goods_id.length === 0 && this.cat_id.length === 0) {
          var req3 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, ' +
              'im.itemimg as itemimg,gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id ' +
              'left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and im.delflg is null or im.delflg = '' and gd.delflg is null "
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req3)
            .then((response) => {
              console.log(response.data)
              that.newTableData = response.data.data
            })
            .catch((response) => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else if (this.goods_id.length === 0 && this.cat_id !== '') {
          var req4 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and (im.delflg is null or im.delflg = '') and gd.delflg is null and gd.cat_id =" +
              this.cat_id
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req4)
            .then((response) => {
              console.log(response.data)
              that.newTableData = response.data.data
            })
            .catch((response) => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
        } else if (this.cat_id !== '' && this.goods_id !== '') {
          var req5 = {
            mode: 'select',
            selectsql:
              'select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, im.itemimg as itemimg,' +
              'gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.sales_type = ' +
              this.salesType +
              " and (im.delflg is null or im.delflg = '') and gd.delflg is null and im.goods_id =" +
              this.goods_id
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req5)
            .then((response) => {
              console.log(response.data)
              that.newTableData = response.data.data
            })
            .catch((response) => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
          console.log(this.tableData)
        } else {
          this.newTableData = []
        }
      }
      this.tableData = this.newTableData
      // レジ金額再計算
      for (var item in this.tableData) {
        if (this.tableData[item].sales_type === 0) {
          this.tableData[item].last_price = this.tableData[item].taxprice
        } else {
          var temp =
            this.tableData[item].taxprice * this.tableData[item].sales_rate
          var temp1 = temp.toString().indexOf('.')
          if (temp1 > 0) {
            this.tableData[item].last_price = temp
              .toString()
              .substring(0, temp1)
          } else {
            this.tableData[item].last_price = temp
          }
        }
      }
      return this.tableData
    },
    catChanged: async function() {
      if (this.$refs['myCascader'].getCheckedNodes()[0]) {
        this.cat_id = this.$refs['myCascader'].getCheckedNodes()[0].data.value
      }
      this.goods_id = ''
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' +
          this.cat_id
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then((response) => {
          console.log(response.data.data)
          this.goodsData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      return this.goodsData
    },
    newCatChanged: async function() {
      if (this.$refs['myCascader2'].getCheckedNodes()[0]) {
        var catId = this.$refs['myCascader2'].getCheckedNodes()[0].data.value
      }

      this.new_goods_id = ''
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' + catId
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then((response) => {
          console.log(response.data)
          this.newGoodsData = response.data.data
        })
        .catch((response) => {
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
        .post(this.$baseUrl + '/web.do', req)
        .then((response) => {})
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log(req)
      console.log('delete!')
      this.getInit()
    },
    // 新規ボタン押下
    itemInsert: function() {
      this.visible = true
      this.itemupdate = false
      this.iteminsert = true
      this.getInit()
      this.form = {}
      this.sub_button = '登録'
      this.title = '新規登録'
      this.sale_show = false
      this.checked = false
    },
    tirggerFile: async function(event) {
      const file = event.target.files[0]
      this.event = null
      const param = new FormData() // 创建form对象
      param.append('file', file) // 通过append向form对象添加数据
      param.append('imgpath', 'item')
      this.formParam = param
      console.log(param.get('file')) // FormData私有类对象，访问不到，可以通过get判断值是否传进去
      if (file) this.form.itemimg = '[NEW FILE]'
      else this.form.itemimg = ''
      console.log('filename:', this.form.itemimg) // FormData私有类对象，访问不到，可以通过get判断值是否传进去
    },
    getInit: async function() {
      this.reset()
      var req1 = {
        mode: 'select',
        selectsql:
          "select im.item_id as item_id,im.item_name as item_name,im.sales_rate as sales_rate,im.sales_type as sales_type,im.item_desp as item_desp,im.price as price,im.taxprice as taxprice,im.unit as unit, im.itemimg as itemimg,gd.goods_name as goods_name,ct.cat_name as cat_name from ns_item im left join ns_goods gd on gd.goods_id = im.goods_id left join ns_cat ct on ct.cat_id = gd.cat_id where im.delflg is null or im.delflg = '' and gd.delflg is null"
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req1)
        .then((response) => {
          console.log(response.data)
          this.newTableData = response.data.data
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      this.tableData = this.newTableData
      for (var item in this.tableData) {
        if (this.tableData[item].sales_type === 0) {
          this.tableData[item].last_price = this.tableData[item].taxprice
        } else {
          var temp =
            this.tableData[item].taxprice * this.tableData[item].sales_rate
          var temp1 = temp.toString().indexOf('.')
          if (temp1 > 0) {
            this.tableData[item].last_price = temp
              .toString()
              .substring(0, temp1)
          } else {
            this.tableData[item].last_price = temp
          }
        }
      }
      console.log(this.tableData)
      return this.tableData
    },
    insertCencle: function() {
      this.$refs['myCascader2'].$refs.panel.clearCheckedNodes()
      this.pathHide = false
      this.visible = false
      this.formParam = ''
      var obj = document.getElementById('imgUpload')
      obj.value = ''
    },
    onSubmit: async function(id) {
      if (!this.form.item_name) {
        alert('品目名を入力して下さい。')
        return
      }
      if (!this.form.item_desp) {
        alert('説明文を入力して下さい。')
        return
      }
      if (!this.form.price) {
        alert('価格を入力して下さい。')
        return
      }
      if (!this.form.unit) {
        alert('単位を入力して下さい。')
        return
      }
      if (!this.form.itemimg) {
        alert('画像をUPLOADして下さい。')
        return
      }

      // 画像保存
      if (this.formParam !== '') {
        await this.axios
          .post(this.$baseUrl + '/image-upload.do', this.formParam)
          .then((response) => {
            console.log('Upload success!')
            console.log(response.data)
            this.form.itemimg = response.data.item_path
          })
          .catch((response) => {
            console.log('Upload error!' + response)
          })
        this.formParam = ''
        var obj = document.getElementById('imgUpload')
        obj.value = ''
      }

      // セール状態判断
      if (this.checked) {
        this.sales_type = 1
        this.sales_rate = this.form.sales_rate
      } else {
        this.sales_type = 0
        this.sales_rate = null
      }
      // 品目更新
      var numReg = new RegExp(/^[0-9]*$/)
      if (id) {
        var req = {
          rscode: 'ok',
          mode: 'update',
          tableName: 'ns_item',
          wheresql: 'item_id =' + id,
          data: {
            item_name: this.form.item_name,
            goods_id: this.form.goods_id,
            item_desp: this.form.item_desp,
            sales_rate: this.sales_rate,
            sales_type: this.sales_type,
            price: numReg.test(this.form.price)
              ? this.form.price
              : this.form.price.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
                return String.fromCharCode(s.charCodeAt(0) - 65248)
              }),
            taxprice: numReg.test(this.form.taxprice)
              ? this.form.taxprice
              : this.form.taxprice.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
                return String.fromCharCode(s.charCodeAt(0) - 65248)
              }),
            unit: this.form.unit,
            itemimg: this.form.itemimg
          }
        }
        console.log(req)
        await this.axios
          .post(this.$baseUrl + '/web.do', req)
          .then((response) => {})
          .catch((response) => {
            console.log('Homepage getGoodsRsp  error!' + response)
          })
        console.log('update!')
        this.visible = false
      } else {
        // 品目新規
        var req2 = {
          mode: 'insert',
          tableName: 'ns_item',
          data: {
            item_name: this.form.item_name,
            goods_id: this.new_goods_id,
            item_desp: this.form.item_desp,
            sales_rate: this.sales_rate,
            sales_type: this.sales_type,
            price: numReg.test(this.form.price)
              ? this.form.price
              : this.form.price.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
                return String.fromCharCode(s.charCodeAt(0) - 65248)
              }),
            taxprice: numReg.test(this.form.taxprice)
              ? this.form.taxprice
              : this.form.taxprice.replace(/[Ａ-Ｚａ-ｚ０-９]/g, function(s) {
                return String.fromCharCode(s.charCodeAt(0) - 65248)
              }),
            unit: this.form.unit,
            itemimg: this.form.itemimg
          }
        }

        await this.axios
          .post(this.$baseUrl + '/web.do', req2)
          .then((response) => {
            console.log(response.data)
          })
          .catch((response) => {
            console.log('Homepage getGoodsRsp  error!' + response)
          })
        console.log('submit!')
      }
      this.pathHide = false
      this.visible = false
      this.sales_rate = null
      this.sales_type = '0'
      this.$refs['myCascader2'].$refs.panel.clearCheckedNodes()
      this.getInit()
    }
  }
}
</script>
