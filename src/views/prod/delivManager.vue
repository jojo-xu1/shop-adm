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
                    <td>注文ID</td>
                    <td>STATUS</td>
                    <td>OPTION</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="item in list" :key="item.UserID">
                    <td scope="row">{{ item.user_id }}</td>
                    <td>
                      <el-link type="primary" @click="showList(item.order_id)">
                        {{ item.order_id }}
                      </el-link>
                    </td>
                    <td>{{ item.status }}</td>
                    <td>
                      <select v-model="selected">
                        <option> --请选择-- </option>
                        <option> 0: '未出荷' </option>
                        <option> 1: '出荷済み' </option>
                        <option> 2: '配達済み' </option>
                        <option> 3: 'キャンセル' </option>
                      </select>
                      <el-button
                        size="mini"
                        @click="itemUpdate(scope.row.item_id)"
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
        :model="userinfo"
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
      </el-form>
      <el-table :data="orderList" show-summary style="width: 100%">
        <el-table-column prop="goods_id" label="id" width="180" />
        <el-table-column prop="goods_name" label="name" width="180" />
        <el-table-column prop="price" label="price" />
      </el-table>
    </el-dialog>
  </div>
</template>

<script>
import draggable from 'vuedraggable'
export default {
  name: 'DeliManager',
  components: { draggable },
  data() {
    return {
      orderVisible: false,
      dragging: false,
      order_id: '',
      status: '',
      user_id: '',
      IDsearch: '',
      list: [],
      orderstatus: [
        { 0: '未出荷' },
        { 1: '出荷済み' },
        { 2: '配達済み' },
        { 3: 'キャンセル' }
      ], // 三元表达式
      selected: '',
      address: [{}],
      orderList: [
        {
          goods_id: '11',
          goods_name: '国内産 きゅうり 3本入 1袋',
          price: '204'
        },
        {
          goods_id: '22',
          goods_name: '刺身酱油2本',
          price: '865'
        },
        {
          goods_id: '33',
          goods_name: '胡瓜20本 名古屋',
          price: '680'
        },
        {
          goods_id: '44',
          goods_name: '生醤油２本　北海道産',
          price: '658'
        }
      ],
      user_name: '',
      user_phone: '',
      user_comment: '',
      user_address: '',
      userinfo: {
        user_name: 'Alice',
        user_phone: '000-111-888',
        user_comment: '午前',
        user_address: 'XXX'
      }
    }
  },
  mounted() {
    this.reFresh()
  },
  methods: {
    async reFresh() {
      var reqlist = {
        mode: 'select',
        selectsql:
          " select d.order_id, d.status, o.user_id from ns_dlv d left join ns_order o on d.order_id = o.order_id where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          console.log(' 初始表： ', response.data)
          this.list = response.data.data
          // this.list = this.goodslist;
          console.log(' list: ', this.list)
          this.setlist()
        })
        .catch((response) => {
          console.log(response)
        })
    },
    async getOrder() {
      var reqlist = {
        mode: 'select',
        selectsql:
          " select d.order_id, d.status, t.item_name, t.item_desp, t.item_price, t.item_num, o.price, s.username from ns_dlv d left join ns_order_detail t on d.order_id = t.order_id left join ns_order o on d.order_id = o.order_id left join sys_users u on u.id = o.user_id where d.last_flg = '1' and (o.delflg is null or o.delflg <> '1') and (u.deleted is null or u.deleted <> '1') "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          console.log(' 初始表： ', response.data)
          this.orderList = response.data.data
          // this.list = this.goodslist;
          console.log(' list: ', this.list)
          console.log(' goodslist： ', this.orderList)
          this.setlist()
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
    orderChanged() {
      this.STATUS = 1
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
