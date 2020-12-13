<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item><el-link type="primary" @click="setlist(0,0)">すべてのカテゴリ</el-link></el-breadcrumb-item>
        <el-breadcrumb-item v-for="(item,temp) in breadList" :key="temp"><el-link type="primary" @click="setbreadlist(item.cat_id)">{{ item.cat_name }}</el-link></el-breadcrumb-item>
      </el-breadcrumb>
      <div class="btn-group">
        <div style="float: left">
          <button
            style="
              background: white;
              height: 35px;
              border-radius: 4px;
              border: 1px solid;
            "
          >
            <a
              :href="this.$baseUrl + '/downloadcsv?sql=select cat_id, cat_name, parent_id, leaf_flag from ns_cat where delflg is null or delflg <> 1'"
            >
              <i class="el-icon-download" />
              CSVダウンロード
            </a>
          </button>
        </div>
        <div style="float: left">
          <el-upload>
            <el-button
              slot="trigger"
              size="small"
              style="
              background: white;
              height: 35px;
              border-radius: 4px;
              border: 1px solid black;
              color: black;
            "
            >
              <i class="el-icon-upload"> CSVアップロード</i>
            </el-button>
          </el-upload>
        </div>
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
                placeholder="カテゴリ名"
              >
              leaf_flag:
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
                <!--<option value="0">leaf_flag</option>-->
                <option value="0">0</option>
                <option value="1">1</option>
              </select>

              <button style="background:white;height:35px;border-radius:4px;border:1px solid;margin:10px" @click="addCat">新規作成</button>
              <el-divider />
            </form>
            <div class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td scope="col">Id</td>
                    <td scope="col">カテゴリ</td>
                    <td scope="col">leaf_flag</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="item in list" :key="item.cat_name">
                    <td scope="row">{{ item.cat_id }}</td>
                    <td><el-link type="primary" @click="setlist(item.cat_id,0)">{{ item.cat_name }}</el-link></td>
                    <td scope="row">{{ item.leaf_flag }}</td>
                    <td>
                      <el-button size="mini" @click="catUp(item.cat_id)">↑</el-button>
                    </td>
                    <td>
                      <el-button size="mini" @click="catDown(item.cat_id)">↓</el-button>
                    </td>
                    <td>
                      <el-button size="mini" @click="catUpdate(item.cat_id,item.cat_name)">変更</el-button>
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        type="danger"
                        @click="catDelete(item.cat_id, item.cat_name) "
                      >削除</el-button> </td>
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
import draggable from 'vuedraggable'
export default {
  name: 'CatManager',
  components: { draggable },
  data() {
    return {
      listall: [],
      dragging: false,
      list: [],
      breadList: [],
      currentid: 0,

      defaultProps: {
        // children: 'children',
        label: 'cat_name'

      },
      count: 1,
      node_had: '',
      resove_had: ''
    }
  },
  mounted() {
    this.setlist(0, 1)
    this.refresh(0)
  },
  methods: {
    async  loadNode(node, resolve) {
      if (node.level === 0) {
        this.node_had = node
        this.resove_had = resolve
        var req = {
          'mode': 'select',
          'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag from ns_cat where delflg=0 or delflg is null'
        }
        await this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
          console.log(response.data)
          this.listall = response.data.data
        }).catch((response) => {
          console.log(response)
        })
        return resolve(this.getnode(0))
      }
      return resolve(this.getnode(node.data.cat_id))
    },
    async refresh(parent_id) {
      var req = {
        'mode': 'select',
        'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag from ns_cat where parent_id= ' + parent_id + ' and (delflg=0 or delflg is null)'
      }
      await this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
        console.log(response.data)
        this.list = []
        this.list = response.data.data
        console.log(response)
      }).catch((response) => {
        console.log(response)
      })
    // console.log(this.list)
    },
    async addCat() {
      var reb = {
        'mode': 'select',
        'selectsql': 'select leaf_flag from ns_cat where cat_id= ' + this.currentid
      }
      var temp
      await this.axios.post(this.$baseUrl + '/web.do', reb).then((response) => {
        console.log(response.data)
        temp = response.data.data[0]
      }).catch((response) => {
        console.log(response)
      })
      if (!temp) {
        temp = { leaf_flag: 0 }
      }
      var cat = {}
      cat.parent_id = this.currentid
      cat.cat_name = document.getElementById('new-todo').value
      cat.leaf_flag = document.getElementById('selected').value
      var data = {}
      data.mode = 'insert'
      data.tableName = 'ns_cat'
      data.data = cat
      var that = this
      if (temp.leaf_flag === 0 || temp.leaf_flag === '') {
        console.log('123', that.currentid)
        this.axios.post(this.$baseUrl + '/web.do', data).then(function(resp) {
          console.log(that.leaf_flag)
          var data = {}
          data.cat_id = resp.data.data
          data.parent_id = that.currentid
          data.cat_name = cat.cat_name
          data.leaf_flag = cat.leaf_flag
          that.listall.push(data)
          that.setlist(that.currentid, 1)
          document.getElementById('new-todo').value = ''
          document.getElementById('selected').value = '0'
          that.node_had.childNodes = []
          that.loadNode(that.node_had, that.resove_had)
        })
      } else {
        alert('カテゴリを所属する商品がありますので、子カテゴリの新規作成はできません')
      }
    },
    catUpdate(id, name) {
      this.$prompt('カテゴリ名を入力してください', name, {
        confirmButtonText: '確認',
        cancelButtonText: 'キャンセル'
      }).then(async({ value }) => {
        var newName = value
        this.$prompt('leaf_flagを0か１で入力してください', name, {
          confirmButtonText: '確認',
          cancelButtonText: 'キャンセル'
        }).then(async({ value }) => {
          var newFlag = value
          this.$message({
            type: 'success',
            message: 'カテゴリを変更しました '
          })
          var resolve = ''
          var that = this
          var req = {
            rscode: 'ok',
            mode: 'update',
            tableName: 'ns_cat',
            wheresql: 'cat_id =' + id,
            data: { cat_name: newName, leaf_flag: newFlag }
          }
          await this.axios
            .post(this.$baseUrl + '/web.do', req)
            .then(response => {
              var req = {
                'mode': 'select',
                'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag from ns_cat where delflg=0 or delflg is null'
              }

              this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
                console.log(response.data)
                this.listall = response.data.data
              }).catch((response) => {
                console.log(response)
              })
              this.refresh(this.currentid)
              that.setlist(this.currentid, 1)
              console.log('update!', this.currentid)
              this.node_had.childNodes = []
              this.loadNode(this.node_had, this.resove_had)
            })
            .catch(response => {
              console.log('Homepage getGoodsRsp  error!' + response)
            })
          console.log(req)
          console.log('update!')
          return resolve(this.getnode(0))
        })
      })
    },
    catDelete(id, name) {
      this.$confirm(name + 'を削除しますか？', '確認', {
        confirmButtonText: '確認',
        cancelButtonText: 'キャンセル',
        type: 'warning'
      }).then(async() => {
        this.$message({
          type: 'success',
          message: name + 'を削除しました！'
        })
        var resolve = ''
        var that = this
        var req = {
          rscode: 'ok',
          mode: 'update',
          tableName: 'ns_cat',
          wheresql: 'cat_id =' + id,
          data: { delflg: 1 }
        }
        await this.axios
          .post(this.$baseUrl + '/web.do', req)
          .then(response => {
            var req = {
              'mode': 'select',
              'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag from ns_cat where delflg=0 or delflg is null'
            }

            this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
              console.log(response.data)
              this.listall = response.data.data
            }).catch((response) => {
              console.log(response)
            })
            this.refresh(this.currentid)
            that.setlist(this.currentid, 1)
            console.log('delete!', this.currentid)
            this.node_had.childNodes = []
            this.loadNode(this.node_had, this.resove_had)
          })
          .catch(response => {
            console.log('Homepage getGoodsRsp  error!' + response)
          })
        console.log(req)
        console.log('delete!')
        return resolve(this.getnode(0))
      })
    },
    addNewTodo() {
    },
    setlist(parent_id, number) {
      this.list = []
      this.currentname = ''
      console.log('123768', parent_id)
      this.currentid = parent_id
      if (parent_id === 0) { this.breadList = [] }
      for (var prop in this.listall) {
        if (parent_id === this.listall[prop].cat_id && number === 0) {
          this.breadList.push(this.listall[prop])
          // console.log(this.leaf_flag)
        }
        // { id: 1, name: '調味料、ビン類',parentid: 0 },
        if (parent_id === this.listall[prop].parent_id) { this.list.push(this.listall[prop]) }
        console.log(this.listall[prop])
      }
      document.getElementById('new-todo').value = ''
      document.getElementById('selected').value = '0'
    },
    setbreadlist(parent_id) {
      var temp = []
      // console.log(123)
      for (var prop in this.breadList) {
        // console.log(this.breadList[prop].parent_id)
        if (parent_id !== this.breadList[prop].parent_id && parent_id !== this.breadList[prop].cat_id) {
          temp.push(this.breadList[prop])
        }
      }
      this.breadList = temp
      // console.log('parent_id', parent_id)

      this.setlist(parent_id, 0)
    },
    getnode(parent_id) {
      var nlist = []
      for (var prop in this.listall) {
        // if(parentid==this.listall[prop].id)
        // { id: 1, name: '調味料、ビン類',parentid: 0 },
        if (parent_id === this.listall[prop].parent_id) { nlist.push(this.listall[prop]) }
        // console.log(this.listall[prop])
      }
      return nlist
    },
    handleNodeClick(data) {

    }
  }
}
</script>

<style>
  .app-container{
    background: #eff0f4;
    height: 1000px;
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

    padding-left:15px;
  }
    .row {
    display: flex;
    align-items: center;
  }
  .bg-purple-light {
    background: #ffffff;

  }
  .grid-content {
    min-height: 36px;
  }
  .row-bg {
    padding: 10px 0;
    background-color: eff0f4;
  }
.table-striped thead th {
  overflow:auto;
background-color: #ffffff;
color: #000000;
border-bottom-width: 0;
}

/* Column Style */
.table-striped td {
  overflow:auto;
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
