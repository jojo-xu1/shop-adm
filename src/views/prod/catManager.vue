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
              :href="this.$baseUrl + '/downloadcsv?sql=select cat_id, cat_name, parent_id, leaf_flag, ns_cat.order_by from ns_cat where delflg is null or delflg <> 1 order by order_by'"
            >
              <i class="el-icon-download" />
              CSVダウンロード
            </a>
          </button>
        </div>
        <div style="float: left">
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
            @click="handleUpload()"
          >
            <i class="el-icon-upload"> CSVアップロード</i>
          </el-button>
        </div>
        <el-dialog
          title="CSVアップロード"
          :visible.sync="uploadvisible"
          width="30%"
          :close-on-click-modal="false"
          :before-close="handleClose"
        >
          <el-upload
            ref="upload"
            class="upload-demo"
            action=""
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :file="file"
            :auto-upload="false"
            accept=".csv"
            :multiple="false"
            :limit="1"
            :on-change="handleChange"
          >
            <el-button
              slot="trigger"
              size="small"
              type="primary"
            >File Select</el-button>
            <el-button
              style="margin-left: 10px"
              size="small"
              type="success"
              @click="submitUpload"
            >Upload</el-button>
            <div slot="tip" class="el-upload__tip">Only CSV File</div>
          </el-upload>
        </el-dialog>
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
              子カテゴリ有無:
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
                <option value="0">あり</option>
                <option value="1">なし</option>
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
                    <td scope="col">子カテゴリ有無</td>
                  </tr>
                </thead>
                <draggable v-model="list" tag="tbody">
                  <tr v-for="(item,index) in list" :key="item.cat_name">
                    <td scope="row">{{ item.cat_id }}</td>
                    <td><el-link type="primary" @click="setlist(item.cat_id,0)">{{ item.cat_name }}</el-link></td>
                    <td scope="row">{{ item.leaf_flag==1 ?"なし":"あり" }}</td>
                    <td>
                      <el-button size="mini" @click="catUp(item.cat_id, item.order_by)">↑</el-button>
                    </td>
                    <td>
                      <el-button size="mini" @click="catDown(item.cat_id, item.order_by)">↓</el-button>
                    </td>
                    <td>
                      <el-button size="mini" @click="catUpdate(item.cat_id,item.cat_name,index)">変更</el-button>
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
    <el-dialog
      title="カテゴリ変更"
      :visible.sync="editvisible"
      width="50%"
      :close-on-click-modal="false"
    >
      <el-form ref="form" :model="editform" label-width="120px" label-position="left">
        <el-form-item label="カテゴリ名">
          <el-input v-model="editform.cat_name" />
        </el-form-item>
        <el-form-item label="子カテゴリ有無">
          <el-select v-model="editform.leaf_flag">
            <el-option label="あり" value="あり" />
            <el-option label="なし" value="なし" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button @click="editvisible = false">キャンセル</el-button>
          <el-button type="primary" @click="onSubmit">変更</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
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
      editform: {
        cat_name: '',
        leaf_flag: ''
      },
      editvisible: false,
      uploadvisible: false,
      form: {
        delivery: false,
        cat_id: ''
      },
      orderForm1: {
        cat_id: '',
        order_by: 0
      },
      orderForm2: {
        cat_id: '',
        order_by: 0
      },
      file: [],
      fileList: [],
      defaultProps: {
        // children: 'children',
        label: 'cat_name'

      },
      count: 1,
      node_had: '',
      resove_had: '',
      change_id: ''
    }
  },
  mounted() {
    this.setlist(0, 1)
    this.refresh(0)
  },
  methods: {
    handlePreview(file) {
      console.log(file)
    },
    async  loadNode(node, resolve) {
      if (node.level === 0) {
        this.node_had = node
        this.resove_had = resolve
        var req = {
          'mode': 'select',
          'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag,ns_cat.order_by from ns_cat where delflg=0 or delflg is null order by order_by'
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
        'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag,ns_cat.order_by from ns_cat where parent_id= ' + parent_id + ' and (delflg=0 or delflg is null) order by order_by'
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
    handleChange(file, fileList) {
      this.fileTemp = file.raw
      if (this.fileTemp) {
        if (
          this.fileTemp.type ===
            'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' ||
          this.fileTemp.type === 'application/vnd.ms-excel'
        ) {
          this.importfxx(this.fileTemp)
        } else {
          this.$message({
            type: 'warning',
            message: '附件格式错误，请删除后重新上传！'
          })
        }
      } else {
        this.$message({
          type: 'warning',
          message: '请上传附件！'
        })
      }
    },
    importfxx(obj) {
      const _this = this
      // const inputDOM = this.$refs.inputer // 通过DOM取文件数据
      this.file = event.currentTarget.files[0]

      var rABS = false // 是否将文件读取为二进制字符串
      var f = this.file

      var reader = new FileReader() // if (!FileReader.prototype.readAsBinaryString) {
      FileReader.prototype.readAsBinaryString = function(f) {
        var binary = ''
        var rABS = false // 是否将文件读取为二进制字符串
        // var pt = this
        var wb // 读取完成的数据
        var outdata
        var reader = new FileReader()
        reader.onload = function(e) {
          var bytes = new Uint8Array(reader.result)
          var length = bytes.byteLength
          for (var i = 0; i < length; i++) {
            binary += String.fromCharCode(bytes[i])
          }
          var XLSX = require('xlsx')
          if (rABS) {
            wb = XLSX.read(btoa(this.fixdata(binary)), {
              // 手动转化
              type: 'base64'
            })
          } else {
            wb = XLSX.read(binary, {
              type: 'binary'
            })
          }
          outdata = XLSX.utils.sheet_to_json(wb.Sheets[wb.SheetNames[0]]) // outdata就是你想要的东西
          console.log('未处理的原始数据如下：')
          console.log(outdata) // 此处可对数据进行处理
          const arr = []
          outdata.map((v) => {
            const obj = {}
            obj.cat_id = v['cat_id']
            obj.cat_name = v['cat_name']
            obj.parient_id = v['parient_id']
            obj.leaf_flag = v['leaf_flag']
            arr.push(obj)
          })
          _this.da = arr
          _this.dalen = arr.length
          return arr
        }
        reader.readAsArrayBuffer(f)
      }
      if (rABS) {
        reader.readAsArrayBuffer(f)
      } else {
        reader.readAsBinaryString(f)
      }
    },
    fixdata(data) { // 文件流转BinaryString
      var o = ''
      var l = 0
      var w = 10240
      for (; l < data.byteLength / w; ++l) o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w, l * w + w)))
      o += String.fromCharCode.apply(null, new Uint8Array(data.slice(l * w)))
      return o
    },
    handleUpload() {
      // console.log(this.msg)
      this.uploadvisible = true
      // console.log(this.$refs.upload.files)
    },
    async submitUpload() {
      var formData = new FormData()
      formData.append('file', this.file)
      console.log('file:', this.file)
      console.log('url:', this.$baseUrl)
      formData.append('tab', 'ns_cat')
      formData.append('cols', 4)
      console.log('url:', this.$baseUrl)
      await this.axios
        .post(this.$baseUrl + '/csvupload', formData)
        .then((response) => {
          console.log('Upload success!')
          console.log(response.data)
          this.$message({
            type: 'success',
            message: 'CSV UPLOADしました '
          })
        })
        .catch((response) => {
          console.log('Upload error!' + response)
        })
      // 清空上传表
      this.file = []
      this.$refs.upload.clearFiles()
    },
    clearFile() {
      this.$refs.clearFile.value = '' // 清空file文件
    },
    handleRemove() {
      this.$refs.upload.clearFiles()
    },

    handleClose(done) {
      this.$confirm('CSVアップロードやめますか')
        .then((_) => {
          this.file = []
          this.$refs.upload.clearFiles()
          done()
        })
        .catch((_) => {})
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

      var req = {
        'mode': 'select',
        'selectsql': 'select order_by from ns_cat where parent_id= ' + this.currentid + ' order by order_by desc'
      }
      var child
      var orderBy = -1
      await this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
        child = response.data.data[0]
      }).catch((response) => {
        console.log(response)
      })
      if (child) {
        orderBy = child.order_by
      }

      var cat = {}
      cat.parent_id = this.currentid
      cat.cat_name = document.getElementById('new-todo').value
      cat.leaf_flag = document.getElementById('selected').value
      cat.order_by = orderBy + 1
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
    catUp(cat_id, order_by) {
      var index = this.list.findIndex(function(cat) {
        return cat.cat_id === cat_id
      })
      if (index > 0) {
        this.updateOrder(cat_id, this.list[index - 1].cat_id, order_by, this.list[index - 1].order_by)
      }
    },
    catDown(cat_id, order_by) {
      var index = this.list.findIndex(function(cat) {
        return cat.cat_id === cat_id
      })
      if (index < this.list.length - 1) {
        this.updateOrder(cat_id, this.list[index + 1].cat_id, order_by, this.list[index + 1].order_by)
      }
    },
    async updateOrder(cat_id1, cat_id2, order1, order2) {
      console.log(cat_id1)
      var req1 = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_cat',
        wheresql: 'cat_id =' + cat_id1,
        data: { order_by: order2 } // swap order1 and order2
      }
      var req2 = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_cat',
        wheresql: 'cat_id =' + cat_id2,
        data: { order_by: order1 } // swap order1 and order2
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', req1)
        .then(this.axios
          .post(this.$baseUrl + '/web.do', req2)
          .then(response => {
            var req = {
              'mode': 'select',
              'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag,ns_cat.order_by from ns_cat where delflg=0 or delflg is null order by order_by'
            }
            this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
              this.listall = response.data.data
            }).catch((response) => {
            })
            this.refresh(this.currentid)
            this.setlist(this.currentid, 1)
            this.node_had.childNodes = []
            this.loadNode(this.node_had, this.resove_had)
          })
          .catch(response => {
          })
        )
      this.getnode(0)
    },
    catUpdate(cat_id, cat_name, index) {
      this.editvisible = true
      this.form.cat_id = cat_id
      this.change_id = cat_id
      this.editform.cat_name = this.list[index].cat_name
      this.editform.leaf_flag = this.list[index].leaf_flag === 1 ? 'なし' : 'あり'
    },
    async onSubmit() {
      this.editvisible = false
      var newName = this.editform.cat_name
      var newFlag = this.editform.leaf_flag === 'なし' ? 1 : 0
      var resolve = ''
      var that = this
      var req = {
        rscode: 'ok',
        mode: 'update',
        tableName: 'ns_cat',
        wheresql: 'cat_id =' + this.change_id,
        data: { cat_name: newName, leaf_flag: newFlag }

      }
      console.log('test12345')
      await this.axios
        .post(this.$baseUrl + '/web.do', req)
        .then(response => {
          var req = {
            'mode': 'select',
            'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag,ns_cat.order_by from ns_cat where delflg=0 or delflg is null order by order_by'
          }
          this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
            console.log(response.data)
            console.log('test1234567')
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
              'selectsql': 'select cat_id, cat_name, parent_id,leaf_flag,ns_cat.order_by from ns_cat where delflg=0 or delflg is null order by order_by'
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
