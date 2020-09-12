<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-link type="primary" href="http://localhost:9527/#/prod/cat-manager">すべてのカテゴリ</el-link>
      <div class="btn-group">
        <vue-json-to-csv
          :json-data="[
            { name: 'Joe', surname: 'Roe' },
            { name: 'John', surname: 'Doe' }
          ]"
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
                v-model="newTodoText"
                style="height:35px;magin-left:5px"
                placeholder=""
              >
              <button style="background:white;height:35px;border-radius:4px;border:1px solid;margin:10px">新規作成</button>
            </form>
            <div class="row">
              <div class="col-auto"><strong>&nbsp;</strong></div>
              <div class="col-auto"><strong>ID</strong></div>
              <div class="col-2"><strong>カテゴリ</strong></div>
            </div>
            <ul>
              <li
                is="todo-item"
                v-for="(todo, index) in todos"
                :key="todo.id"
                :title="todo.title"
                @remove="todos.splice(index, 1)"
              />
            </ul>
          </div>
        </div>
      </el-col>
      <el-col :span="8"><div class="grid-content bg-purple-light" /></el-col>
    </el-row>
    <p>項目の順番はドラッグ＆ドロップでも変更可能です。</p>
  </div>
</template>

<script>
import VueJsonToCsv from 'vue-json-to-csv'
export default {
  name: 'CatManager',
  components: { VueJsonToCsv },

  data() {
    return {
      msg: 'xxx'
    }
  },
  methods: {
    gotolink() {
      // 指定跳转地址
      this.$router.replace('http://netengine.sakura.ne.jp/event-ec/shopadm/setting/shop/csv/5')
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
</style>
