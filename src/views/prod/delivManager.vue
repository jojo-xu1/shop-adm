<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><el-link
          type="primary"
          @click="setlist()"
        >すべての注文</el-link></el-breadcrumb-item>
      </el-breadcrumb>
    </div>
    <el-row :gutter="15">
      <el-col :span="16">
        <div class="grid-content bg-purple">
          <div id="todo-list-example">
            <form @submit.prevent="orderSearch">
              注文ID：
              <input
                id="IDsearch"
                style="height: 35px; magin-left: 5px"
                placeholder=" "
              >

              注文状態:
              <select
                id="selected"
                style="
                  background: white;
                  height: 35px;
                  border-radius: 4px;
                  border: 1px solid black;
                  color: black;
                "
              >
                <!--<option value="0">子カテゴリ有無</option>-->
                <option value="0">未出荷</option>
                <option value="1">出荷済み</option>
                <option value="2">配達済み</option>
                <option value="3">キャンセル</option>
              </select>

              <button
                style="
                  background: white;
                  height: 35px;
                  border-radius: 4px;
                  border: 1px solid;
                  margin: 10px;
                "
                @click="orderSearch"
              >
                検索
              </button>
              <el-divider />
            </form>
            <div class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td>UserID</td>
                    <td>注文番号</td>
                    <td>配達状態</td>
                    <td>OPTION</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="(item, index) in list" :key="item.UserID">
                    <td scope="row">{{ item.user_id }}</td>
                    <td>
                      <el-link
                        type="primary"
                        @click="
                          getOrder(item.order_id);
                          orderVisible = true;
                        "
                      >
                        {{ item.order_info_id }}
                      </el-link>
                    </td>
                    <td>{{ statusName(item.status) }}</td>
                    <td>
                      <el-button
                        size="mini"
                        @click="handleEdit(item.order_id, index)"
                      >変更</el-button>
                    </td>
                  </tr>
                </draggable>
              </table>
            </div>
          </div>
        </div>
      </el-col>
    </el-row>

    <el-dialog
      title="注文LIST"
      :visible.sync="orderVisible"
      width="40%"
      :close-on-click-modal="false"
    >
      <el-form
        status-icon
        label-width="100px"
        class="demo-ruleForm"
      >
        <el-form-item label="名前">
          <span>{{ userinfo[0].user_id }}</span>
        </el-form-item>
        <el-form-item label="電話番号">
          <span>{{ userinfo[0].number }}</span>
        </el-form-item>
        <el-form-item label="配達指示">
          <span>{{ userinfo[0].arrival_time }}</span>
        </el-form-item>
        <el-form-item label="住所">
          <span>{{ userinfo[0].dlv_address }}</span>
        </el-form-item>
        <el-form-item label="配達状態">
          <span>{{ statusName(userinfo[0].status) }}</span>
        </el-form-item>
      </el-form>
      <el-table
        :data="orderList"
        show-summary
        sum-text="合計"
        style="width: 100%"
      >
        <el-table-column prop="item_name" label="商品名" width="180" />
        <el-table-column prop="item_num" label="数量" width="180" />
        <el-table-column prop="item_price" label="合計" />
      </el-table>
    </el-dialog>

    <el-dialog
      title="配達状態変更"
      :visible.sync="editVisible"
      width="40%"
      :close-on-click-modal="false"
    >
      <el-form
        status-icon
        label-width="100px"
        class="demo-ruleForm"
      >
        <el-form-item label="名前">
          <span>{{ userinfo[0].user_id }}</span>
        </el-form-item>
        <el-form-item label="電話番号">
          <span>{{ userinfo[0].number }}</span>
        </el-form-item>
        <el-form-item label="配達指示">
          <span>{{ userinfo[0].arrival_time }}</span>
        </el-form-item>
        <el-form-item label="住所">
          <span>{{ userinfo[0].dlv_address }}</span>
        </el-form-item>
        <el-form-item label="配達状態">
          <span>{{ statusName(userinfo[0].status) }}</span>
        </el-form-item>
        <el-form-item label="配達状態">
          <el-select v-model="editform.status">
            <el-option label="未出荷" value="0" />
            <el-option label="出荷中" value="1" />
            <el-option label="配達済み" value="2" />
            <el-option label="キャンセル" value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="onSubmit">変更</el-button>
        </el-form-item>
      </el-form>
      <el-table
        :data="orderList"
        show-summary
        sum-text="合計"
        style="width: 100%"
      >
        <el-table-column prop="item_name" label="商品名" width="180" />
        <el-table-column prop="item_num" label="数量" width="180" />
        <el-table-column prop="item_price" label="合計" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
// import { status } from 'nprogress'
import draggable from 'vuedraggable'
import Vue from 'vue'
Vue.filter('dataFormat', function(value, fmt) {
  const getDate = new Date(value)
  const o = {
    'M+': getDate.getMonth() + 1,
    'd+': getDate.getDate(),
    'h+': getDate.getHours(),
    'm+': getDate.getMinutes(),
    's+': getDate.getSeconds(),
    'q+': Math.floor((getDate.getMonth() + 3) / 3),
    S: getDate.getMilliseconds()
  }
  if (/(y+)/.test(fmt)) {
    fmt = fmt.replace(
      RegExp.$1,
      (getDate.getFullYear() + '').substr(4 - RegExp.$1.length)
    )
  }
  for (const k in o) {
    if (new RegExp('(' + k + ')').test(fmt)) {
      fmt = fmt.replace(
        RegExp.$1,
        RegExp.$1.length === 1 ? o[k] : ('00' + o[k]).substr(('' + o[k]).length)
      )
    }
  }
  return fmt
})
export default {
  name: 'DeliManager',
  components: { draggable },
  data() {
    return {
      orderVisible: false,
      editVisible: false,
      dragging: false,
      order_id: '',
      status: '',
      user_id: '',
      IDsearch: '',
      list: [],
      orderstatus: [],
      selected: '',
      address: [{}],
      orderList: [],
      user_name: '',
      user_phone: '',
      user_comment: '',
      dlv_address: '',
      price: '',
      item_name: '',
      statusname: '',
      item_num: '',
      item_price: '',
      editform: {
        status: ''
      },
      userinfo: [
        { user_name: '', user_phone: '', user_comment: '', dlv_address: '' }
      ],
      form: {
        delivery: false,
        order_id: ''
      }
    }
  },
  mounted() {
    this.reFresh()
  },
  methods: {
    async reFresh() {
      var that = this
      var reqlist = {
        mode: 'select',
        selectsql:
          ' select d.order_id, d.status, o.order_info_id, o.user_id, o.dlv_address from ns_dlv d  ' +
          ' left join ns_order o on d.order_id = o.order_id ' +
          ' left join ns_user_list u on u.user_id = o.user_id ' +
          " where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          console.log(' 初始表： ', response.data)
          that.list = response.data.data
          // this.list = this.goodslist;
          console.log(' list: ', that.list)
        })
        .catch((response) => {
          console.log(response)
        })
    },
    async getOrder(order_id) {
      var that = this
      console.log('order_id:', order_id)

      var reqlist = {
        mode: 'select',
        selectsql:
          ' select d.status, o.price, t.item_name, t.item_num, t.item_price,o.dlv_address from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_order_detail t on d.order_id = t.order_id where d.order_id = ' +
          order_id +
          " and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          that.orderList = response.data.data
          console.log(' 商品列表： ', that.orderList)
          for (var i = 0; i <= that.orderList.length; i++) {
            that.orderList[i].item_price =
              that.orderList[i].item_price * that.orderList[i].item_num
          }
        })
        .catch((response) => {
          console.log(response)
        })
      var reqlist2 = {
        mode: 'select',
        selectsql:
          ' select d.status, o.dlv_address, o.arrival_time, ad.number, o.user_id from ns_dlv d left join ns_order o  on d.order_id = o.order_id left join ns_user_address ad on ad.address =o.dlv_address where d.order_id = ' +
          order_id +
          " and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist2)
        .then((response) => {
          that.userinfo = response.data.data
          console.log(' userinfo： ', that.userinfo)
          console.log('收货地址：', that.userinfo[0].dlv_address)
        })
        .catch((response) => {
          console.log(response)
        })
    },
    setlist() {
      this.reFresh()
      console.log('All Order')
    },
    statusName(status) {
      if (status === '0') {
        return '未出荷'
      } else if (status === '1') {
        return '出荷中'
      } else if (status === '2') {
        return '配達済み'
      } else {
        return 'キャンセル'
      }
    },
    async orderSearch() {
      console.log('search button')
      var that = this
      var searchid = document.getElementById('IDsearch').value
      console.log('select:', document.getElementById('selected').value)
      console.log('ID:', document.getElementById('IDsearch').value)
      if (searchid === '') {
        console.log('id空，状态检索')
        var reqlist = {
          mode: 'select',
          selectsql:
            " select d.order_id, d.status, o.order_info_id, o.user_id, o.dlv_address from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_user_list u on u.user_id = o.user_id where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') and d.status = " +
            document.getElementById('selected').value
        }
        await this.axios
          .post(this.$baseUrl + '/web.do', reqlist)
          .then((response) => {
            console.log(' 初始表： ', response.data)
            that.list = response.data.data
            // this.list = this.goodslist;
            console.log(' list: ', that.list)
            console.log(' list.status: ', that.list[1].status)
          })
          .catch((response) => {
            console.log(response)
          })
      } else {
        console.log('ID有，ID检索')
        var reqlist2 = {
          mode: 'select',
          selectsql:
            " select d.order_id, d.status, o.order_info_id, o.user_id, o.dlv_address from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_user_list u on u.user_id = o.user_id where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') and o.order_info_id = " +
            document.getElementById('IDsearch').value
        }
        await this.axios
          .post(this.$baseUrl + '/web.do', reqlist2)
          .then((response) => {
            console.log(' 初始表： ', response.data)
            that.list = response.data.data
            // this.list = this.goodslist;
            console.log(' list: ', that.list)
            console.log(' list.status: ', that.list[1].status)
          })
          .catch((response) => {
            console.log(response)
          })
      }
    },
    showList() {
      this.orderVisible = true
    },
    closeList() {
      this.orderVisible = false
    },
    formatDate(value) {
      const date = new Date(value)
      const y = date.getFullYear()
      let MM = date.getMonth() + 1
      MM = MM < 10 ? '0' + MM : MM
      let d = date.getDate()
      d = d < 10 ? '0' + d : d
      let h = date.getHours()
      h = h < 10 ? '0' + h : h
      let m = date.getMinutes()
      m = m < 10 ? '0' + m : m
      let s = date.getSeconds()
      s = s < 10 ? '0' + s : s
      return y + '-' + MM + '-' + d + ' ' + h + ':' + m + ':' + s
    },
    async handleEdit(order_id, index) {
      console.log('index:', index)
      console.log('id:', order_id)
      this.form.order_id = order_id
      var that = this
      var reqlist2 = {
        mode: 'select',
        selectsql:
          ' select d.status, o.dlv_address, o.arrival_time, ad.number, o.user_id from ns_dlv d left join ns_order o  on d.order_id = o.order_id left join ns_user_address ad on ad.address =o.dlv_address where d.order_id = ' +
          order_id +
          " and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist2)
        .then((response) => {
          that.userinfo = response.data.data
          console.log(' userinfo： ', that.userinfo)
          console.log('收货地址：', that.userinfo[0].dlv_address)
        })
        .catch((response) => {
          console.log(response)
        })
      var reqlist = {
        mode: 'select',
        selectsql:
          ' select d.status, o.price, t.item_name, t.item_num, t.item_price,o.dlv_address from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_order_detail t on d.order_id = t.order_id where d.order_id = ' +
          order_id +
          " and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          that.orderList = response.data.data
          console.log('response.data.data', response.data.data)
          for (var i = 0; i < that.orderList.length; i++) {
            that.orderList[i].item_price =
              that.orderList[i].item_price * that.orderList[i].item_num
          }
          that.editVisible = true
          console.log('aaaaaaaaaaa')
          console.log(
            '%c%s',
            'color: red; background: yellow; font-size: 24px;',
            index
          )
          console.log('orderList', that.orderList)
          that.editform.status = that.orderList[0].status
          console.log('xxxxxxxxxxxxx')
          console.log('status:', that.orderList[0].status)
        })
        .catch((response) => {
          console.log(response)
        })
    },
    async onSubmit() {
      // console.log("SubmitTest:status=", this.form.status);
      // 修改旧状态flg
      var oldStatus = {}
      oldStatus.last_flg = 0
      var req2 = {
        mode: 'update',
        tableName: 'ns_dlv',
        data: oldStatus,
        wheresql: ' order_id = ' + this.form.order_id + ' and last_flg = 1 '
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req2)
        .then((response) => {
          console.log('RESPONSE.DATA:', response.data)
          //  插入新状态flg
          var date1 = new Date()
          var dateTime = this.formatDate(Date.parse(date1))
          var orderInfoId = Math.round(Math.random() * 10000000000)
          console.log(orderInfoId)
          var statusdata = {}
          statusdata.order_id = this.form.order_id
          statusdata.status = this.editform.status
          statusdata.last_flg = 1
          statusdata.createtime = dateTime
          statusdata.createtime = dateTime
          var dataNewstatus = {}
          dataNewstatus.mode = 'insert'
          dataNewstatus.tableName = 'ns_dlv'
          dataNewstatus.data = statusdata
          console.log('dataNewstatus', dataNewstatus)
          this.axios
            .post(this.$baseUrl + '/web.do', dataNewstatus)
            .then(function(resp) {
              console.log('resp信息：', resp)
              // var data = {};
              // data.status = status;
            })
          console.log('插入新状态OK')
        })
        .catch((response) => {
          console.log('Homepage getGoodsRsp  error!' + response)
        })
      console.log('旧状态变更ok')

      this.reFresh()
      this.editVisible = false
    }
  }
}
</script>

<style>
.app-container {
  background: #eff0f4;
  height: 1000px;
  font-size: 14px;
}
.app-header {
  height: 50px;
  display: flex;
  align-items: center;
}
.btn-group {
  margin-left: auto;
}
.btn-btn-button {
  background: #ffffff;
}
.el-row {
  background: #eff0f4;
  margin-bottom: 15px;
}
.bg-purple {
  background: #ffffff;
  /* height: 380px; */
  padding-left: 15px;
}
.row {
  display: flex;
  align-items: center;
}
.bg-purple-light {
  background: #ffffff;
  /* height: 250px; */
}
.grid-content {
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: eff0f4;
}
.table-striped thead th {
  background-color: #ffffff;
  overflow: auto;
  color: #000000;
  border-bottom-width: 0;
}
/* Column Style */
.table-striped td {
  color: #000;
  border-collapse: collapse;
  overflow: auto;
}
/* Heading and Column Style */
.table-striped tr,
.table-striped th {
  border-width: 0px;
  border-style: solid;
}
/* Padding and font style */
.table-striped td,
.table-striped th {
  padding: 8px 20px;
  font-size: 14px;
  font-family: Verdana;
  font-weight: bold;
}
</style>
