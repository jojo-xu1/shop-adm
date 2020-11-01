<template>
  <div id="itemForm">
    <el-dialog :title="title" :close-on-click-modal="false" :visible.sync="visible">
      <el-form ref="form" :model="form" label-width="80px">
        <el-form-item label="カテゴリ">
          <el-select v-model="cat_id" placeholder="カテゴリ名" @change="catChanged">
            <el-option
              v-for="colg in catData"
              :key="colg.cat_id"
              :label="colg.cat_name"
              :value="colg.cat_id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="商品">
          <el-select v-model="goods_id" placeholder="商品名" @change="goodsChanged">
            <el-option
              v-for="goods in goodsData"
              :key="goods.goods_id"
              :label="goods.goods_name"
              :value="goods.goods_id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="品目名">
          <el-input v-model="form.name" />
        </el-form-item>
        <el-form-item label="税抜き">
          <el-input v-model="form.price">円</el-input>
        </el-form-item>
        <el-form-item label="税込">
          <el-input v-model="form.tax">円</el-input>
        </el-form-item>
        <el-form-item label="画像URL">
          <el-input v-model="form.path" type="textarea" />
        </el-form-item>
        <el-form-item label="品目詳細">
          <el-input v-model="form.desc" type="textarea" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSubmit">登録</el-button>
          <el-button @click="visible = false">キャンセル</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script>
export default {
  name: 'AddOrUpdate',
  data() {
    return {
      title: '新规',
      visible: '',
      catId: '',
      goodsId: '',
      itemId: '',
      cat_id: '',
      goods_id: '',
      catData: [],
      goodsData: [],
      form: {
        delivery: false
      }
    }
  },
  mounted: function() {
    this.getInit()
  },
  methods: {
    init() {
      // this.form.id = id || 0;
      this.visible = true
      this.$nextTick(() => {})
      // console.log(this.goodsId);
      // console.log(this.catId);
    },
    getInit: async function() {
      var req = {
        mode: 'select',
        selectsql: 'select * from ns_cat where delflg is null '
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log(response.data)
          this.catData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      return this.catData
    },
    catChanged: async function(value) {
      console.log(value)
      this.catId = value
      var req = {
        mode: 'select',
        selectsql:
          'select * from ns_goods where delflg is null and cat_id =' + value
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
    goodsChanged: function(value) {
      console.log(value)
      this.goodsId = value
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
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log(response.data)
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log(req)
      console.log('submit!')
    }
  }
}
</script>

<style>
</style>
