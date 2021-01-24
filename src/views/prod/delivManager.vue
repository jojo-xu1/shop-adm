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
              <el-input
                v-model="IDsearch"
                style="width: 200px"
                prefix-icon="el-icon-search"
                size="small"
                placeholder=" "
              />

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
                        {{ item.order_id }}
                      </el-link>
                    </td>
                    <td>{{ item.status }}</td>
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
        ref="userinfo"
        status-icon
        label-width="100px"
        class="demo-ruleForm"
      >
        <el-form-item label="名前" prop="user_name">
          <span>{{ userinfo.user_name }}</span>
        </el-form-item>
        <el-form-item label="電話番号" prop="user_phone">
          <span>{{ userinfo.user_phone }}</span>
        </el-form-item>
        <el-form-item label="配達指示" prop="user_comment">
          <span>{{ userinfo.user_comment }}</span>
        </el-form-item>
        <el-form-item label="住所" prop="user_address">
          <span>{{ userinfo.user_address }}</span>
        </el-form-item>
        <el-form-item label="配達状態" prop="status">
          <span>{{ userinfo.user_address }}</span>
        </el-form-item>
      </el-form>
      <el-table :data="orderList" show-summary style="width: 100%">
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
        ref="orderList"
        status-icon
        label-width="100px"
        class="demo-ruleForm"
      >
        <el-form-item label="名前" prop="user_name">
          <span>{{ userinfo.user_name }}</span>
        </el-form-item>
        <el-form-item label="電話番号" prop="user_phone">
          <span>{{ userinfo.user_phone }}</span>
        </el-form-item>
        <el-form-item label="配達指示" prop="user_comment">
          <span>{{ userinfo.user_comment }}</span>
        </el-form-item>
        <el-form-item label="住所" prop="user_address">
          <span>{{ userinfo.user_address }}</span>
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
      <el-table :data="orderList" show-summary style="width: 100%">
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
      orderstatus: [
        { 0: '未出荷' },
        { 1: '輸送中' },
        { 2: '配達済み' },
        { 3: 'キャンセル' }
      ],
      selected: '',
      address: [{}],
      orderList: [],
      user_name: '',
      user_phone: '',
      user_comment: '',
      user_address: '',
      price: '',
      item_name: '',
      statusname: '',
      item_num: '',
      item_price: '',
      editform: {
        status: ''
      },
      userinfo: {
        user_name: 'Alice',
        user_phone: '000-111-888',
        user_comment: '午前',
        user_address: 'XXX'
      },
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
          " select d.order_id, d.status, o.user_id from ns_dlv d left join ns_order o on d.order_id = o.order_id where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          console.log(' 初始表： ', response.data)
          that.list = response.data.data
          // this.list = this.goodslist;
          console.log(' list: ', that.list)
          that.setlist()
          that.statusname
          for (var i = 0; i < that.list.length; i++) {
            if (that.status === 0) {
              that.statusname = '未発送'
            } else if (that.status === 1) {
              that.statusname = '輸送中'
            } else if (that.status === 2) {
              that.statusname = '到着'
            } else {
              that.statusname = 'キャンセル'
            }
          }
        })
        .catch((response) => {
          console.log(response)
        })
    },
    async getOrder(order_id) {
      var that = this
      var reqlist = {
        mode: 'select',
        selectsql:
          " select d.status, o.price, t.item_name, t.item_num, t.item_price from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_order_detail t on d.order_id = t.order_id where d.order_id = '" +
          order_id +
          "' and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          that.orderList = response.data.data
          for (var i = 0; i <= that.orderList.length; i++) {
            that.orderList[i].item_price =
              that.orderList[i].item_price * that.orderList[i].item_num
          }
          console.log(' list: ', that.list)
          console.log(' 商品列表： ', that.orderList)
          that.setlist()
        })
        .catch((response) => {
          console.log(response)
        })
    },
    setlist() {
      console.log('All Order')
    },
    orderSearch() {
      console.log('search button')
    },
    showList() {
      this.orderVisible = true
    },
    closeList() {
      this.orderVisible = false
    },
    async handleEdit(order_id, index) {
      console.log('index:', index)
      console.log('id:', order_id)
      this.form.order_id = order_id
      var that = this
      var reqlist = {
        mode: 'select',
        selectsql:
          " select d.status, o.price, t.item_name, t.item_num, t.item_price from ns_dlv d left join ns_order o on d.order_id = o.order_id left join ns_order_detail t on d.order_id = t.order_id where d.order_id = '" +
          order_id +
          "' and d.last_flg = 1 and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          that.orderList = response.data.data
          console.log('response.data.data', response.data.data)
          for (var i = 0; i < that.orderList.length; i++) {
            that.orderList[i].item_price = that.orderList[i].item_price * that.orderList[i].item_num
          }
          that.editVisible = true
          console.log('aaaaaaaaaaa')
          console.log('%c%s', 'color: red; background: yellow; font-size: 24px;', index)
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
      console.log('SubmitTest:status=', this.form.status)
      var status = {}
      status.status = this.editform.status
      var dataNewstatus = {}
      dataNewstatus.mode = 'update'
      dataNewstatus.tableName = 'ns_dlv'
      dataNewstatus.data = status
      dataNewstatus.wheresql = ' order_id = ' + this.form.order_id
      console.log('dataNewstatus', dataNewstatus)
      await this.axios
        .post(this.$baseUrl + '/web.do', dataNewstatus)
        .then(function(resp) {
          console.log('resp信息：', resp)
          var data = {}
          data.status = status
        })
      console.log('BBBBBBBBBBBBBBBBBBBBBBBBB')
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
