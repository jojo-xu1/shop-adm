<template>
  <div v-show="show" class="modal-bg" @mousemove="modalMove" @mouseup="cancelMove">
    <div class="modal-container">
      <div class="modal-header" @mousedown="setStartingPoint">
        {{ title }}
      </div>
      <div class="modal-main">
        <slot />
        <div class="content">

          <div class="infoC">

            <div class="imgInfo">

              <img :src="rspjson.rsp_img" width="250px" height="250px" alt="">
              <div>
                {{ rspjson.rep_desp }}
              </div>
            </div>
            <div class="msgInfo">
              <div style="margin-top:0px">
                <table width="100%">
                  <tr>
                    <td colspan="5">
                      <span class="rsp-desp">{{ rspjson.rsp_metial }}{{ rspData }}</span>
                    </td>
                  </tr>

                  <tr>
                    <td width="10px" />
                    <td>
                      <el-cascader ref="myCascader" :props="fatherCatData" placeholder="カテゴリ" @change="catChanged" />
                      <el-select ref="sel_gds" v-model="goods_id" placeholder="商品名">
                        <el-option
                          v-for="goods in goodsData"
                          :key="goods.goods_id"
                          :label="goods.goods_name"
                          :value="goods.goods_id"
                        />
                      </el-select>
                    </td>
                    <td align="right">
                      所要量<br>
                      <el-input v-model="rgds_amount" />
                    </td>
                    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>
                    <td align="center">
                      <el-button type="success" plain @click="addMetial()">追加</el-button>
                    </td>

                  </tr>

                  <tr v-for="item in itemList" :key="item.goods_id">
                    <td width="10px" />
                    <td>
                      &nbsp;&nbsp;&nbsp;&nbsp;{{ item.goods_name }}
                    </td>
                    <td align="right">{{ item.rgds_amount }}</td>
                    <td>&nbsp;&nbsp;&nbsp;&nbsp;</td>

                    <td>
                      <el-popconfirm title="削除するか？" @onConfirm="RspGoodsDel(item.rgds_id)">
                        <el-button slot="reference" size="mini" type="danger">删除</el-button>
                      </el-popconfirm>
                    </td>

                  </tr>

                </table>

              </div>
            </div>
          </div>
        </div>

      </div>
      <div class="modal-footer">
        <el-button type="primary" round @click="hidePop">閉じる</el-button>
      </div>
    </div>

  </div>

  <!-- レシビPOP -->

</template>

<script>
import axios from 'axios'
export default {
  name: 'RspPop',
  props: {
    show: {
      type: Boolean,
      default: false
    },
    rspid: {
      type: String,
      default: ''
    }
  },
  data() {
    return {
      x: 0,
      y: 0,
      node: null,
      isCanMove: false,
      rspjson: {},
      itemList: [],
      title: '',
      fatherCatData: {
        lazy: true,
        lazyLoad(node, resolve) {
          var req = {}
          if (node.level === 0) {
            req = {
              mode: 'select',
              selectsql: "select cat_id,cat_name,leaf_flag from ns_cat where parent_id = '0' and delflg is null "
            }
          } else {
            req = {
              mode: 'select',
              selectsql: 'select cat_id,cat_name,leaf_flag from ns_cat where parent_id = ' + node.data.value
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
            .catch(err => {
              console.log(err)
            })
        }
      },
      catData: [],
      goodsData: [],
      cat_id: '',
      goods_id: '',
      rgds_amount: ''
    }
  },
  computed: {
    // 计算属性的 getter
    rspData: function() {
      this.init()
      return ''
    }
  },
  mounted() {
    this.node = document.querySelector('.modal-container')
    this.init()
  },
  methods: {
    init: async function() {
      var rsp = {}

      var req = {
        mode: 'select',
        selectsql:
            "select rsp_id, rsp_name, rep_desp, rsp_img, rsp_metial from ns_rsp where (delflg is null or delflg <> '1') and rsp_id=" + this.rspid
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log('Before RspPop show')
          console.log(response.data)
          rsp = response.data.data[0]
        })
        .catch(response => {
          console.log('Before Update select   error!' + response)
        })
      this.title = rsp.rsp_name
      rsp.rsp_img = this.$webUrl + '/shopping/upimg/' + rsp.rsp_img

      // 材料明細取得
      req = {
        mode: 'select',
        selectsql:
            "select a.rgds_id, a.goods_id, a.rsp_id, a.rgds_amount, g.goods_name from ns_rspgoods a left join ns_goods g on g.goods_id = a.goods_id where (a.delflg is null or a.delflg <> '1') and a.rsp_id=" + this.rspid
      }
      var that = this
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          console.log('rspGoods List')
          console.log(response.data)
          that.itemList = response.data.data
        })
        .catch(response => {
          console.log('Before Update select   error!' + response)
        })
        //
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

      // `this` 指向 vm 实例
      this.rspjson = rsp
      return rsp
    },
    addMetial: async function() {
      if (!this.goods_id) {
        alert('商品を選択して下さい。')
        return
      }
      if (!this.rgds_amount) {
        alert('所要量を入力して下さい。')
        return
      }
      // 新規
      var req2 = {
        mode: 'insert',
        tableName: 'ns_rspgoods',
        data: {
          goods_id: this.goods_id,
          rgds_amount: this.rgds_amount,
          rsp_id: this.rspid
        }
      }

      await this.axios
        .post(this.$baseUrl + '/web.do', req2)
        .then(response => {
          console.log('add rspGoods ok.')
          console.log(response.data)
        })
        .catch(response => {
          console.log('add rspGoods error!' + response)
        })

      this.init()
    },
    RspGoodsDel: async function(id) {
      console.log(id)
      var req = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_rspgoods',
        wheresql: 'rgds_id =' + id,
        data: { delflg: '1' }
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {})
        .catch(response => {
          console.log('rspgoods delete error!' + response)
        })
      console.log(req)
      console.log('delete!')
      this.init()
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
        .then(response => {
          console.log(response.data.data)
          this.goodsData = response.data.data
        })
        .catch(response => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })

      return this.goodsData
    },
    hidePop() {
      this.$emit('hidePop')
    },

    submitPop() {
      this.$emit('submitPop')
    },

    setStartingPoint(e) {
      this.x = e.clientX - this.node.offsetLeft
      this.y = e.clientY - this.node.offsetTop
      this.isCanMove = true
    },

    modalMove(e) {
      if (this.isCanMove) {
        this.node.style.left = e.clientX - this.x + 'px'
        this.node.style.top = e.clientY - this.y + 'px'
      }
    },

    cancelMove() {
      this.isCanMove = false
    },

    submit() {

    }
  }
}
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
.rsp-desp{
  color:rgba(172, 71, 67, 0.5);
  font-size:16px;
}
.modal-bg {
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background: rgba(0,0,0,.5);
    z-index: 10;
}
.modal-container {
    background: #fff;
    border-radius: 10px;
    overflow: hidden;
    position: fixed;
    top: 50%;
    left: 50%;
    transform: translate(-50%,-50%);
}
.modal-header {
    height: 56px;
    background: #409EFF;
    color: #fff;
    display: flex;
    align-items: center;
    justify-content: center;
    cursor: move;
}
.modal-footer {
    display: flex;
    align-items: center;
    justify-content: center;
    height: 57px;
    border-top: 1px solid #ddd;
}
.modal-footer button {
    width: 100px;
}
.modal-main {
    padding: 15px 40px;
}

.content{
  display: flex;
  justify-content: center;
}
.infoC{
  display: flex;
  justify-content: center;
  width: 800px;
  background: white;
  margin-top: 00px;
  height: 100%;
  padding: 20px;
  padding-left: 40px;
  padding-right: 40px;
  box-shadow: rgba(0, 0, 0, 0.12) 0px 2px 4px, rgba(0, 0, 0, 0.04) 0px 0px 6px;
}
.msgInfo{
  width: 550px;
  font-size: 12px;
}
.imgInfo{
  width: 250px;
  color: #00cccc;
}
.item-c{
  display: flex;
  justify-content:space-between;
}
.itemdesp{
  color: rgb(151, 54, 130);
  font-size: 12px;
  text-decoration:underline
}
</style>
