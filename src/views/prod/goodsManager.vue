<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <el-link type="primary" @click="setAllgoods()">すべてのGOODS</el-link>
        </el-breadcrumb-item>
        <!-- <el-breadcrumb-item v-for="(item,key) in breadList" :key="key">
          <el-link type="primary" @click="setbreadList(item.cat_id)">{{ item.cat_name }}</el-link>
        </el-breadcrumb-item>-->
      </el-breadcrumb>
      <div class="btn-group">
        <vue-json-to-csv :json-data="list" :labels="{ name: { title: 'First name' } }">
          <button style="background:white;height:35px;border-radius:4px;border:1px solid">
            <i class="el-icon-download" />
            CSVダウンロード
          </button>
        </vue-json-to-csv>
        <button
          style="background:white;height:35px;border-radius:4px;border:1px solid"
          @click="gotolink"
        >
          <i class="el-icon-setting" />
          CSV出力項目設定
        </button>
      </div>
    </div>
    <el-row :gutter="15">
      <el-col :span="16">
        <div class="grid-content bg-purple">
          <div id="todo-list-example">
            <form @submit.prevent="addNewTodo">
              <input id="new-todo" style="height:35px; magin-left:5px" placeholder>
              <button
                style="background:white; height:35px; border-radius:4px; border:1px solid; margin:10px"
                @click="addGoods"
              >新規作成</button>
              <el-divider />
            </form>
            <div class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td>Id</td>
                    <td>カテゴリ</td>
                    <td>Goods</td>
                    <td>OPTION</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="item in list" :key="item.goods_id">
                    <td scope="row">{{ item.goods_id }}</td>
                    <td>
                      <el-link type="primary">{{ item.cat_name }}</el-link>
                    </td>
                    <td>
                      <el-link type="primary" @click="setlist(item.cat_id)">{{ item.goods_name }}</el-link>
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border:none"
                        icon="el-icon-top"
                        @click="handleTop(scope.$index, tableData)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border:none"
                        icon="el-icon-bottom"
                        @click="handleBtm(scope.$index, tableData)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border:none"
                        icon="el-icon-edit"
                        @click="handleEdit(scope.$index, tableData)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border:none"
                        icon="el-icon-delete"
                        @click.prevent="handleDelete(item.cat_id)"
                      />
                    </td>
                  </tr>
                </draggable>
              </table>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="grid-content bg-purple-light">
          <el-tree
            ref="tree"
            :props="defaultProps"
            :load="loadNode"
            lazy
            @node-click="handleNodeClick"
          />
          <!-- <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />-->
        </div>
      </el-col>
    </el-row>
    <p>項目の順番はドラッグ＆ドロップでも変更可能です。</p>
  </div>
</template>

<script>
// import { node } from 'clipboard'
import VueJsonToCsv from 'vue-json-to-csv'
import draggable from 'vuedraggable'
export default {
  name: 'GoodsManager',
  components: { VueJsonToCsv, draggable },
  data() {
    return {
      treelist: [],
      goodslist: [],
      goods_id: 0,
      goods_name: '',
      cat_id: -1,
      dragging: false,
      list: [],
      currentname: '',
      currentid: 5,
      breadList: [],
      defaultProps: {
        // children: 'children',
        label: 'cat_name'
      },
      count: 1
    }
  },
  mounted() {
    var reqlist = {
      mode: 'select',
      selectsql:
        " select g.cat_id, g.goods_name, g.goods_id, c.cat_name, c.leaf_flag from ns_goods g left join ns_cat c on g.cat_id = c.cat_id where g.delflg is null or g.delflg <> '1' "
    }
    this.$axios
      .post('http://13.112.112.160:8080/test/web.do', reqlist)
      .then((response) => {
        console.log(' 初始表： ', response.data)
        this.list = response.data.data
        this.goodslist = response.data.data
      })
      .catch((response) => {
        console.log(response)
      })
  },
  methods: {
    async loadNode(node, resolve) {
      console.log('loadtest')
      if (node.level === 0) {
        var req = {
          mode: 'select',
          selectsql: 'select cat_id, cat_name, parent_id, leaf_flag from ns_cat'
        }
        await this.$axios
          .post('http://13.112.112.160:8080/test/web.do', req)
          .then((response) => {
            //  console.log("数据库连接test");
            //  console.log(response);
            this.treelist = response.data.data
            //  console.log("查看读取数据");
            //  console.log(this.treelist);
          })
          .catch((response) => {
            //  console.log(response);
          })
        return resolve(this.getnode(0))
      }
      // console.log("123");
      return resolve(this.getnode(node.data.cat_id))
    },
    gotolink() {
      // 指定跳转地址
      this.$router.replace(
        'http://netengine.sakura.ne.jp/event-ec/shopadm/setting/shop/csv/5'
      )
    },
    addGoods() {
      var goods = {}
      goods.cat_id = this.currentid
      goods.goods_name = document.getElementById('new-todo').value
      var data = {}
      data.mode = 'insert'
      data.tableName = 'ns_goods'
      data.data = goods
      var that = this
      this.$axios
        .post('http://13.112.112.160:8080/test/web.do', data)
        .then(function(resp) {
          //  console.log("resp信息：", resp);
          var data = {}
          data.goods_id = resp.data.data
          data.cat_id = that.currentid
          data.goods_name = goods.goods_name
          that.goodslist.push(data)
          data.cat_name = that.currentname
          that.setlist(that.currentid)
        })

      var leaf_flag = {}
      leaf_flag.leaf_flag = '1'
      var dataleaf = {}
      dataleaf.mode = 'update'
      dataleaf.tableName = 'ns_cat'
      dataleaf.data = leaf_flag
      dataleaf.wheresql = ' cat_id = ' + this.currentid
      console.log('dataleaf', dataleaf)
      this.$axios
        .post('http://13.112.112.160:8080/test/web.do', dataleaf)
        .then(function(resp) {
          console.log('resp信息：', resp)
          var data = {}
          data.leaf_flag = leaf_flag
        })
    },
    // addNew() {
    //   var cat = {
    //     //  根据id和name，设定一个对象，调用数组的相关方法，添加到data的list中，
    //     cat_id: this.cat_id,
    //     cat_name: document.getElementById("new-todo").value,
    //     parent_id: this.currentid,
    //   };
    //   this.list.push(cat);
    // },
    // handleDelete() {
    //   //  根据id删除数据，
    //   //  1.如何根据id找到此项索引； 2.找到索引，调用splice方法
    //   //  some根据指定的条件进行判断
    //   this.list.some((item, i) => {
    //     if (item.cat_id === cat_id) {
    //       // 从索引为i的地方开始删除1个
    //       this.list.splice(i, 1)
    //       return ture
    //     }
    //   })
    // },
    addNewTodo() {},
    setAllgoods() {
      //  console.log("AllgoodsTest")
      this.list = this.goodslist
    },
    setlist(cat_id) {
      //  console.log("setlist测试");
      this.list = []
      // this.currentname = "";
      this.currentid = cat_id

      // if (
      //   cat_id === 5 ||
      //   cat_id === 6 ||
      //   cat_id === 7 ||
      //   cat_id === 8 ||
      //   cat_id === 9 ||
      //   cat_id === 10
      // ) {
      //   this.breadList = [];
      // }
      for (var prop in this.goodslist) {
        //    console.log("list", this.list);
        //    console.log("goodslist", this.goodslist);
        // if (cat_id === this.goodslist[prop].id) {
        //   this.currentname = this.goodslist[prop].goods_name;
        // }
        // if (cat_id === this.goodslist[prop].cat_id) {
        //   this.breadList.push(this.goodslist[prop]);
        // }
        if (cat_id === this.goodslist[prop].cat_id) {
          this.list.push(this.goodslist[prop])
        }
      }
      //  console.log("当前表", this.list);
      console.log('breadlist', this.breadList)
    },
    setbreadList(cat_id) {
      var temp = []
      console.log('setBreadlistTest')
      for (var prop in this.breadList) {
        console.log(this.breadList[prop].cat_id)
        if (
          cat_id !== this.breadList[prop].cat_id &&
          cat_id !== this.breadList[prop].goods_id
        ) {
          temp.push(this.breadList[prop])
        }
      }
      this.breadList = temp
      console.log('cat_id', cat_id)

      this.setlist(cat_id)
    },
    getnode(parent_id) {
      var nlist = []
      for (var prop in this.treelist) {
        // if(parent_id==this.treelist[prop].cat_id)
        // { cat_id: 1, cat_name: '調味料、ビン類',parent_id: 0 },
        if (parent_id === this.treelist[prop].parent_id) {
          nlist.push(this.treelist[prop])
        }
        // console.log(this.treelist[prop])
      }
      return nlist
    },
    // nodeKeytest() {
    //   console.log('node:', node - key)
    // },
    handleNodeClick(node, data, value) {
      // if (node.parent_id !== 0 || node.cat_id !== node.parent_id) {
      console.log('nodeclick:', node)
      if (node.leaf_flag) {
        //  console.log("node.cat_id:" + node.cat_id);
        // this.$router.push({cat_name:'main',params:{cat_id:node.cat_id}})
        console.log('nodeclick:', node)
        // console.log("data:", data);
        // console.log("value:", value);
        this.currentname = node.cat_name
        this.currentid = node.cat_id
        this.setlist(node.cat_id)
        //  console.log("currentname", this.currentname);
      }
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
