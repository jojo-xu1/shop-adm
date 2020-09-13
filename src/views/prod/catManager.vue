<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><el-link type="primary" @click="setlist(0)">すべてのカテゴリ</el-link></el-breadcrumb-item>
        <el-breadcrumb-item><el-link type="primary">{{ currentname }}</el-link></el-breadcrumb-item>
      </el-breadcrumb>
      <div class="btn-group">
        <vue-json-to-csv
          :json-data="list"
          :labels="{ name: { title: 'First name' } }"
        >
          <button style="background:white;height:35px;border-radius:4px;border:1px solid">
            <i class="el-icon-download" />
            CSVダウンロード
          </button>
        </vue-json-to-csv>
        <button style="background:white;height:35px;border-radius:4px;border:1px solid" @click="gotolink">
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
              <input
                id="new-todo"
                style="height:35px;magin-left:5px"
                placeholder=""
              >
              <button style="background:white;height:35px;border-radius:4px;border:1px solid;margin:10px" @click="addCat">新規作成</button>
              <el-divider />
            </form>
            <div class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td scope="col">Id</td>
                    <td scope="col">カテゴリ</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="item in list" :key="item.name">
                    <td scope="row">{{ item.id }}</td>
                    <td><el-link type="primary" @click="setlist(item.id)">{{ item.name }}</el-link></td>
                    <td /><td /><td /><td /><td /><td />
                    <td />
                    <td><i class="el-icon-top" /> </td>
                    <td><i class="el-icon-bottom" /> </td>
                    <td><i class="el-icon-edit" /> </td>
                    <td><i class="el-icon-delete" /> </td>
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
            :props="defaultProps"
            :load="loadNode"
            lazy
          />
          <!-- <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />-->
        </div>
      </el-col>
    </el-row>
    <p>項目の順番はドラッグ＆ドロップでも変更可能です。</p>
  </div>
</template>

<script>
import VueJsonToCsv from 'vue-json-to-csv'
import draggable from 'vuedraggable'
export default {
  name: 'CatManager',
  components: { VueJsonToCsv, draggable },
  data() {
    return {
      listall: [
        { id: 1, name: '調味料、ビン類', parentid: 0 },
        { id: 2, name: '野菜・くだもの', parentid: 0 },
        { id: 3, name: '肉類', parentid: 0 },
        { id: 4, name: '飲み物', parentid: 0 },
        { id: 5, name: '醤油類', parentid: 1 },
        { id: 6, name: '油', parentid: 1 },
        { id: 7, name: '根菜', parentid: 2 },
        { id: 8, name: '長根菜', parentid: 7 }
      ],
      dragging: false,
      list: [],
      currentname: '',
      currentid: 0,
      defaultProps: {
        // children: 'children',
        label: 'name'

      },
      count: 1
    }
  },
  mounted() {
    this.setlist(0)
    // console.log(this.list)
  },
  methods: {
    loadNode(node, resolve) {
      if (node.level === 0) {
        return resolve(this.getnode(0))
      }
      console.log(resolve(this.getnode(node.data.id)))
      return resolve(this.getnode(node.data.id))
    },
    gotolink() {
      // 指定跳转地址
      this.$router.replace('http://netengine.sakura.ne.jp/event-ec/shopadm/setting/shop/csv/5')
    },
    addCat() {
      var cat = {}
      cat.parent_id = this.currentid
      cat.cat_name = document.getElementById('new-todo').value
      var data = {}
      data.mode = 'insert'
      data.tableName = 'ns_cat'
      data.data = cat
      this.$axios.post('http://127.0.0.1/test/web.do', data).then(function(resp) {
        console.log(resp)
      })
    },
    addNewTodo() {
    },
    setlist(parentid) {
      this.list = []
      this.currentname = ''
      this.currentid = parentid
      for (var prop in this.listall) {
        if (parentid === this.listall[prop].id) { this.currentname = this.listall[prop].name }
        // { id: 1, name: '調味料、ビン類',parentid: 0 },
        if (parentid === this.listall[prop].parentid) { this.list.push(this.listall[prop]) }
        // console.log(this.listall[prop])
      }
    },
    getnode(parentid) {
      var nlist = []
      for (var prop in this.listall) {
        // if(parentid==this.listall[prop].id)
        // { id: 1, name: '調味料、ビン類',parentid: 0 },
        if (parentid === this.listall[prop].parentid) { nlist.push(this.listall[prop]) }
        // console.log(this.listall[prop])
      }
      return nlist
    },
    handleNodeClick(data) {
      console.log(data)
    }
  }
}
</script>

<style>
  .app-container{
    background: #eff0f4;
    height: 800px;
    font-size: 14px;
  }
  .app-header{
    height: 50px;
    display: flex;
    align-items: center;

  }
  .btn-group{
    margin-left: auto;
  }
  .btn-btn-button{
    background: #ffffff;
  }
  .el-row {
    background: #eff0f4;
    margin-bottom: 15px;
  }

  .bg-purple {
    background: #ffffff;
    height: 380px;
    padding-left:15px;
  }
    .row {
    display: flex;
    align-items: center;
  }
  .bg-purple-light {
    background: #ffffff;
    height: 250px;
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
color: #000000;
border-bottom-width: 0;
}

/* Column Style */
.table-striped td {
color: #000;
border-collapse: collapse;
}
/* Heading and Column Style */
.table-striped tr, .table-striped th {
border-width: 0px;
border-style: solid;
}

/* Padding and font style */
.table-striped td, .table-striped th {
padding: 8px 20px;
font-size: 14px;
font-family: Verdana;
font-weight: bold;
}
</style>
