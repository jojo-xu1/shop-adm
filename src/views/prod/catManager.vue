<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><el-link type="primary">すべてのカテゴリ</el-link></el-breadcrumb-item>
        <el-breadcrumb-item><el-link>{{ parent }}</el-link></el-breadcrumb-item>
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
            </form>
            <div class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <th scope="col">Id</th>
                    <th scope="col">Name</th>
                    <th scope="col">Sport</th>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="item in list" :key="item.name">
                    <td scope="row">{{ item.id }}</td>
                    <td><el-link type="primary">{{ item.name }}</el-link></td>
                    <td><i class="el-icon-top" /> </td>
                  </tr>
                </draggable>
              </table>
            </div>
          </div>
        </div>
      </el-col>
      <el-col :span="8">
        <div class="grid-content bg-purple-light">
          <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />
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
      listData: [
        { id: 1, name: 'Abby', sport: 'basket', children: [{ id: 7, name: 'bbb' }] },
        { id: 2, name: 'Brooke', sport: 'foot', children: [{ id: 7, name: 'bbb' }] },
        { id: 3, name: 'Courtenay', sport: 'volley', children: [{ id: 7, name: 'bbb' }] },
        { id: 4, name: 'David', sport: 'rugby', children: [{ id: 7, name: 'bbb' }] },
        { id: 5, name: 'David', sport: 'rugby', children: [{ id: 7, name: 'bbb' }] }
      ],
      list: [
        { id: 1, name: 'Abby', sport: 'basket' },
        { id: 2, name: 'Brooke', sport: 'foot' },
        { id: 3, name: 'Courtenay', sport: 'volley' },
        { id: 4, name: 'David', sport: 'rugby' }
      ],
      dragging: false,
      parent: '',
      defaultProps: {
        children: 'children',
        label: 'name'
      }
    }
  },
  methods: {
    gotolink() {
      // 指定跳转地址
      this.$router.replace('http://netengine.sakura.ne.jp/event-ec/shopadm/setting/shop/csv/5')
    },
    addCat() {
      var cat = {}
      cat.id = '6'
      cat.name = document.getElementById('new-todo').value
      cat.sport = 'ddddd'
      this.list.push(cat)
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
    height: 280px;
    padding-left:15px;
  }
    .row {
    display: flex;
    align-items: center;
  }
  .bg-purple-light {
    background: #ffffff;
    height: 200px;
  }
  .grid-content {
    min-height: 36px;
  }
  .row-bg {
    padding: 10px 0;
    background-color: eff0f4;
  }
.table-striped thead th {
background-color: rgb(156, 186, 95);
color: #fff;
border-bottom-width: 0;
}

/* Column Style */
.table-striped td {
color: #000;
}
/* Heading and Column Style */
.table-striped tr, .table-striped th {
border-width: 1px;
border-style: solid;
border-color: rgb(156, 186, 95);
}

/* Padding and font style */
.table-striped td, .table-striped th {
padding: 5px 10px;
font-size: 12px;
font-family: Verdana;
font-weight: bold;
}
</style>
