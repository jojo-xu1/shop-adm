<template>
  <div id="items">
    <span>カテゴリ :</span>
    <el-select ref="sel_cat" v-model="cat_id" placeholder="カテゴリ名" @change="catChanged">
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

    <br>
    <el-button type="primary" @click="search">检索</el-button>
    <el-button type="info" @click="reset">リセット</el-button>
    <el-button type="primary" @click="itemInsert">新規登録</el-button>

    <el-table :data="tableData" style="width: 100%">
      <el-table-column label="レシピID" width="90">
        <template slot-scope="scope">
          <span style="margin-left: 10px">{{ scope.row.rsp_id }}</span>
        </template>
      </el-table-column>
      <el-table-column prop="rsp_name" label="レシピ名" width="180" />
      <el-table-column prop="rep_desp" label="レシピ紹介文" width="260" />
      <el-table-column prop="rsp_img" label="レシピ画像Path" width="180" />
      <el-table-column prop="rsp_metial" label="何人分" width="180" />

      <el-table-column label="操作">
        <template slot-scope="scope">
          <el-button size="mini" @click="itemUpdate(scope.row.rsp_id)">変更</el-button>
          <el-popconfirm title="削除するか？" @onConfirm="itemDelete(scope.row.rsp_id)">
            <el-button slot="reference" size="mini" type="danger">删除</el-button>
          </el-popconfirm>

          <el-button size="mini" @click="rspGoodsWin(scope.row.rsp_id)">材料明細リスト</el-button>

        </template>
      </el-table-column>
    </el-table>
    <div>

      <el-dialog :title="title" :close-on-click-modal="false" :visible.sync="visible">
        <el-form ref="form" :rules="rules" :model="form" label-width="80px">

          <el-form-item label="レシピID" hidden="true">
            <el-input v-model="form.rsp_id" />
          </el-form-item>
          <el-form-item label="レシピ名" prop="rsp_name">
            <el-input v-model="form.rsp_name" />
          </el-form-item>
          <el-form-item label="何人分" prop="rsp_metial">
            <el-input v-model="form.rsp_metial" />
          </el-form-item>
          <el-form-item label="レシピ紹介文">
            <el-input v-model="form.rep_desp" prop="rep_desp" />
          </el-form-item>
          <el-form-item label="画像URL">
            <el-input v-model="form.rsp_img" prop="itemimg" />
            <div class="file_box">
              <span class="upload">
                <input type="file" value="画像選択" accept="image/*" @change="tirggerFile($event)">
                <img :src="form.rsp_img" alt>
              </span>
            </div>
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="onSubmit(form.rsp_id)">{{ sub_button }}</el-button>
            <el-button @click="visible = false">キャンセル</el-button>
          </el-form-item>
        </el-form>
      </el-dialog>
    </div>

    <!-- レシビPOP -->
    <RspPop :show="popshow" :title="poptitle" :rspid="current_rspid" @hidePop="hidePop" @submitPop="submitPop" />

  </div>
</template>

<script>
import RspPop from '@/components/RspPop'
export default {
  name: 'MenuSetting',
  components: { RspPop },
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
      formParam: '',
      catData: [],
      goodsData: [],
      tableData: [],
      newTableData: [],
      popshow: false,
      poptitle: '',
      current_rspid: '',

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
      },
      rules: {
        rsp_name: [
          { required: true, message: 'レシピ名を入力ください', trigger: 'blur' },
          { min: 1, max: 50, message: '50桁数以内', trigger: 'blur' }
        ],
        rsp_metial: [
          {
            required: true,
            message: '何人分を入力ください',
            trigger: 'change'
          },
          { min: 1, max: 50, message: '50桁数以内', trigger: 'blur' }
        ],
        rep_desp: [
          {
            required: true,
            message: 'レシピ紹介文を入力ください',
            trigger: 'change'
          },
          { min: 1, max: 200, message: '200桁数以内', trigger: 'blur' }
        ]
      }
    }
  },
  mounted: function() {
    this.getInit()
  },
  methods: {
    hidePop() {
      // 取消弹窗回调
      this.popshow = false
    },
    submitPop() {
      // 确认弹窗回调
      this.popshow = false
    },
    rspGoodsWin(rspid) {
      this.current_rspid = String(rspid)
      this.popshow = true
      this.poptitle = 'Huang liyan OK'
    },
    itemUpdate: async function(id) {
      // alert( 'id:' + id)
      this.visible = true
      this.title = 'レシピ更新'
      this.sub_button = '更新'
      this.form = {}

      var req = {
        mode: 'select',
        selectsql:
          "select rsp_id, rsp_name, rep_desp, rsp_img, rsp_metial from ns_rsp where (delflg is null or delflg <> '1') and rsp_id=" + id
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log('Before Update select OK')
          console.log(response.data)
          this.form = response.data.data[0]
        })
        .catch(response => {
          console.log('Before Update select   error!' + response)
        })
    },
    // 選択条件リセット
    reset: function() {
      this.cat_id = ''
      this.goodsData = []
      this.goods_id = ''
    },

    // 品目検索
    search: async function() {
      var that = this
      console.log(this.saleTypes)

      var req1 = {
        mode: 'select',
        selectsql:
          "select rsp_id, rsp_name, rep_desp, rsp_img, rsp_metial from ns_rsp where delflg is null or delflg <> '1'"
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req1)
        .then(response => {
          console.log(response.data)
          that.newTableData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      this.tableData = this.newTableData

      return this.tableData
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
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log(response.data)
          this.goodsData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      return this.goodsData
    },
    itemDelete: async function(id) {
      console.log(id)
      var req = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_rsp',
        wheresql: 'rsp_id =' + id,
        data: { delflg: '1' }
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {})
        .catch(response => {
          console.log('rsp delete error!' + response)
        })
      console.log(req)
      console.log('delete!')
      this.getInit()
    },
    itemInsert: function() {
      this.visible = true
      this.getInit()
      this.form = {}

      this.sub_button = '登録'
      this.title = '新規登録'
    },
    async tirggerFile(event) {
      const file = event.target.files[0]
      let param = new FormData() // 创建form对象
      param.append('file', file) // 通过append向form对象添加数据
      param.append('imgpath', 'rsp') // 通过append向form对象添加数据
      this.formParam = param
      console.log(param.get('file')) // FormData私有类对象，访问不到，可以通过get判断值是否传进去
      if (file) this.form.rsp_img = '[NEW FILE]'
      else this.form.rsp_img = ''
      param = ''
    },

    getInit: async function() {
      var req1 = {
        mode: 'select',
        selectsql:
          "select rsp_id, rsp_name, rep_desp, rsp_img, rsp_metial from ns_rsp where delflg is null or delflg <> '1'"
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req1)
        .then(response => {
          console.log(response.data)
          this.tableData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      console.log(this.tableData)
      this._getInit()
      return this.tableData
    },
    _getInit: async function() {
      var req2 = {
        mode: 'select',
        selectsql: "select * from ns_cat where (delflg is null or delflg <> '1') and leaf_flag='1'"
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req2)
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
      if (!this.form.rsp_name) {
        alert('レシピ名を入力して下さい。')
        return
      }
      if (!this.form.rsp_metial) {
        alert('材料説明文を入力して下さい。')
        return
      }
      if (!this.form.rep_desp) {
        alert('レシピ紹介文を入力して下さい。')
        return
      }
      if (!this.form.rsp_img) {
        alert('レシピ画像をUPLOADして下さい。')
        return
      }
      // rsp_img

      // 画像保存
      if (this.formParam !== '') {
        console.log('Upload start!')
        await this.axios
          .post(
            this.$baseUrl + '/image-upload.do',
            this.formParam
          )
          .then(response => {
            console.log('Upload success!')
            console.log(response.data)
            this.form.rsp_img = response.data.rsp_path
            this.formParam = ''
          })
          .catch(response => {
            console.log('Upload error!' + response)
          })
      }

      // レシピ更新
      if (id) {
        var req = {
          rscode: 'ok',
          mode: 'update',
          tableName: 'ns_rsp',
          wheresql: 'rsp_id =' + id,
          data: {
            rsp_name: this.form.rsp_name,
            rep_desp: this.form.rep_desp,
            rsp_img: this.form.rsp_img,
            rsp_metial: this.form.rsp_metial
          }
        }
        console.log(req)
        await this.axios
          .post(this.$baseUrl + '/web.do', req)
          .then(response => {

          })
          .catch(response => {
            console.log('Rsp Upate error!' + response)
          })
        console.log('update!')
        this.visible = false
      } else {
        // レシピ新規
        // var formData = new FormData()

        var req2 = {
          mode: 'insert',
          tableName: 'ns_rsp',
          data: {
            rsp_name: this.form.rsp_name,
            rep_desp: this.form.rep_desp,
            rsp_img: this.form.rsp_img,
            rsp_metial: this.form.rsp_metial
          }
        }

        await this.axios
          .post(this.$baseUrl + '/web.do', req2)
          .then(response => {
            console.log('add rsp ok.')
            console.log(response.data)
          })
          .catch(response => {
            console.log('add rsp error!' + response)
          })
      }

      this.visible = false
      this.sales_rate = null
      this.sales_type = '0'
      this.formParam = ''
      this.search()
    }
  }
}
</script>
