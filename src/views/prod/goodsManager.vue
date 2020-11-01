<template>
  <div id="tagMain" class="app-container">
    <div class="app-header">
      <el-breadcrumb separator="/">
        <el-breadcrumb-item>
          <el-link type="primary" @click="setAllgoods()">すべてのGOODS</el-link>
        </el-breadcrumb-item>
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
              :href="
                this.$baseUrl +
                  '/downloadcsv?sql=select g.cat_id, g.goods_name, g.goods_id, c.cat_name, c.leaf_flag from ns_goods g left join ns_cat c on g.cat_id = c.cat_id where g.delflg is null or g.delflg <> 1'
              "
            >
              <i class="el-icon-download" />
              CSVダウンロード
            </a>
          </button>

          <!-- <button
              style="
                background: white;
                height: 35px;
                border-radius: 4px;
                border: 1px solid;
              "
              @click="handleDownload()"
            > <i class="el-icon-download" />
              CSVダウンロード

            </button> -->
        </div>
        <!-- <button
          style="
            background: white;
            height: 35px;
            border-radius: 4px;
            border: 1px solid;
          "
          type="file"
          ref="upload"
          @click="uploadHandle"
        >
          <i class="el-icon-upload"> CSVアップロード</i>
        </button> -->
        <!--
===========================================================
 -->

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
        >
          <el-upload
            ref="upload"
            class="upload-demo"
            action="      "
            :on-preview="handlePreview"
            :on-remove="handleRemove"
            :file-list="fileList"
            :auto-upload="false"
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

        <!-- <div style="float: left">
          <el-upload
            ref="upload"
            action=""
            data=""
            :file-list="fileList"
            :on-preview="handlePreview"
            :show-file-list="false"
          >
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
        </div> -->

        <!--
===========================================================
 -->
      </div>
    </div>
    <el-row :gutter="15">
      <el-col :span="16">
        <div class="grid-content bg-purple">
          <div id="todo-list-example">
            <form @submit.prevent="addNewTodo">
              <input
                id="new-todo"
                style="height: 35px; magin-left: 5px"
                placeholder
              >
              <button
                style="
                  background: white;
                  height: 35px;
                  border-radius: 4px;
                  border: 1px solid;
                  margin: 10px;
                "
                @click="addGoods"
              >
                新規作成
              </button>
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
                      <el-link type="primary" @click="setlist(item.cat_id)">{{
                        item.goods_name
                      }}</el-link>
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border: none"
                        icon="el-icon-top"
                        @click="handleTop(scope.$index, tableData)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border: none"
                        icon="el-icon-bottom"
                        @click="handleBtm(scope.$index, tableData)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border: none"
                        icon="el-icon-edit"
                        @click="handleEdit(item.goods_id)"
                      />
                    </td>
                    <td>
                      <el-button
                        size="mini"
                        style="border: none"
                        icon="el-icon-delete"
                        @click="handleDelete(item.goods_id)"
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

    <el-dialog
      title="商品编辑"
      :visible.sync="editvisible"
      width="30%"
      :close-on-click-modal="false"
    >
      <el-form ref="form" :model="form" label-width="80px">
        <el-form-item label="商品名">
          <el-input v-model="form.goods_name" />
        </el-form-item>
        <el-form-item>
          <el-button @click="editvisible = false">キャンセル</el-button>
          <el-button type="primary" @click="onSubmit">登録</el-button>
        </el-form-item>
      </el-form>
    </el-dialog>
  </div>
</template>

<script>
// import { node } from 'clipboard'

import draggable from 'vuedraggable'
export default {
  name: 'GoodsManager',
  components: { draggable },
  data() {
    return {
      treelist: [],
      goodslist: [],
      goods_id: 0,
      tempid: 0,
      goods_name: '',
      cat_id: -1,
      dragging: false,
      list: [],
      currentname: '',
      currentid: -1,
      breadList: [],
      editvisible: false,
      uploadvisible: false,
      fileList: [],
      defaultProps: {
        // children: 'children',
        label: 'cat_name'
      },
      count: 1,
      form: {
        delivery: false,
        goods_id: ''
      }
    }
  },
  mounted() {
    this.reFresh()
  },
  methods: {
    handlePreview(file) {
      console.log(file)
    },
    // tree加载
    async loadNode(node, resolve) {
      console.log('loadtest')
      if (node.level === 0) {
        var req = {
          mode: 'select',
          selectsql:
            'select cat_id, cat_name, parent_id, leaf_flag from ns_cat'
        }
        await this.axios
          .post(this.$baseUrl + '/web.do', req)
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
    // 刷新载入页面
    async reFresh() {
      var reqlist = {
        mode: 'select',
        selectsql:
          " select g.cat_id, g.goods_name, g.goods_id, c.cat_name, c.leaf_flag from ns_goods g left join ns_cat c on g.cat_id = c.cat_id where g.delflg is null or g.delflg <> '1' "
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqlist)
        .then((response) => {
          console.log(' 初始表： ', response.data)

          this.goodslist = response.data.data
          // this.list = this.goodslist;
          console.log(' list: ', this.list)
          console.log(' goodslist： ', this.goodslist)
          this.setlist(this.currentid)
        })
        .catch((response) => {
          console.log(response)
        })
    },
    gotolink() {
      // 指定跳转地址
      this.$router.replace(
        'http://netengine.sakura.ne.jp/event-ec/shopadm/setting/shop/csv/5'
      )
    },
    // upload csv file弹出框
    handleUpload() {
      // console.log(this.msg)
      this.uploadvisible = true
      console.log(this.$refs.upload.files)
    },
    submitUpload() {
      this.$refs.upload.submit().then(() => {
        // 回调函数
      })
    },
    // handleRemove(file, fileList) {
    //   console.log(file, fileList)
    // },
    // handlePreview(file) {
    //   console.log(file)
    // },
    // handleDownload() {
    //   this.axios
    //     .get("http://13.112.112.160:8080/test/downloadcsv?sql=select cat_id, goods_name, goods_id from ns_goods")
    //     .then((response) => {
    //       console.log(response)
    //     })
    //     .catch((response) => {

    //     });
    // },
    // handleDownload() {
    //   this.axios({
    //     url:
    //       'http://13.112.112.160:8080/test/downloadcsv?sql=select cat_id, goods_name, goods_id from ns_goods', // 接口名字
    //     method: 'get',
    //     params: {},
    //     responseType: 'blob'
    //   }).then(function(response) {
    //     const blob = new Blob([response.data], {
    //       type:
    //         'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;charset=utf-8'
    //     })
    //     const aEle = document.createElement('a') // 创建a标签
    //     const href = window.URL.createObjectURL(blob) // 创建下载的链接
    //     aEle.href = href
    //     aEle.download = execlName // 下载后文件名
    //     document.body.appendChild(aEle)
    //     aEle.click() // 点击下载
    //     document.body.removeChild(aEle) // 下载完成移除元素
    //     window.URL.revokeObjectURL(href) // 释放掉blob对象
    //   })
    // },
    // 新增商品
    addGoods() {
      var goods = {}
      goods.cat_id = this.currentid
      goods.goods_name = document.getElementById('new-todo').value
      var data = {}
      data.mode = 'insert'
      data.tableName = 'ns_goods'
      data.data = goods
      var that = this
      this.axios.post(this.$baseUrl + '/web.do', data).then(function(resp) {
        //  console.log("resp信息：", resp);
        var data = {}
        data.goods_id = resp.data.data
        data.cat_id = that.currentid
        data.goods_name = goods.goods_name
        that.goodslist.push(data)
        data.cat_name = that.currentname
        that.setlist(that.currentid)
        document.getElementById('new-todo').value = ''
      })
      // 修改为叶节点
      // var leaf_flag = {}
      // leaf_flag.leaf_flag = 1
      // var dataleaf = {}
      // dataleaf.mode = 'update'
      // dataleaf.tableName = 'ns_cat'
      // dataleaf.data = leaf_flag
      // dataleaf.wheresql = ' cat_id = ' + this.currentid
      // console.log('dataleaf', dataleaf)
      // this.axios
      //   .post(this.$baseUrl + '/web.do', dataleaf)
      //   .then(function(resp) {
      //     console.log('resp信息：', resp)
      //     var data = {}
      //     data.leaf_flag = leaf_flag
      //   })
    },
    // 编辑商品名
    handleEdit(goods_id) {
      this.editvisible = true
      this.form.goods_id = goods_id
      console.log('goodsid', goods_id)
    },
    async onSubmit() {
      this.visible = false
      console.log('SubmitTest:goods_id=', this.form.goods_id)
      var goods_name = {}
      goods_name.goods_name = this.form.goods_name
      var dataNewname = {}
      dataNewname.mode = 'update'
      dataNewname.tableName = 'ns_goods'
      dataNewname.data = goods_name
      dataNewname.wheresql = ' goods_id = ' + this.form.goods_id
      console.log('dataNewname', dataNewname)
      await this.axios
        .post(this.$baseUrl + '/web.do', dataNewname)
        .then(function(resp) {
          console.log('resp信息：', resp)
          var data = {}
          data.goods_name = goods_name
        })
      this.reFresh()
      console.log('crid', this.currentid)
      this.setlist(this.currentid)
    },
    // 删除商品
    async handleDelete(goods_id) {
      console.log('delTEST')
      this.$confirm('商品を削除しますか？', '確認', {
        confirmButtonText: '確認',
        cancelButtonText: 'キャンセル',
        type: 'warning'
      }).then(async() => {
        this.$message({
          type: 'success',
          message: '削除しました！'
        })
        var delflg = {}
        delflg.delflg = '1'
        var datadel = {}
        datadel.mode = 'update'
        datadel.tableName = 'ns_goods'
        datadel.data = delflg
        datadel.wheresql = ' goods_id = ' + goods_id
        console.log('datadel', datadel)
        await this.axios
          .post(this.$baseUrl + '/web.do', datadel)
          .then(function(resp) {
            console.log('resp信息：', resp)
            var data = {}
            data.delflg = delflg
          })
        this.reFresh()
        console.log('crid', this.currentid)
        this.setlist(this.currentid)
      })
    },
    addNewTodo() {},
    // 显示allgoods
    setAllgoods() {
      //  console.log("AllgoodsTest")
      this.list = this.goodslist
    },
    // 显示分类
    setlist(cat_id) {
      //  console.log("setlist测试");
      this.list = []
      // this.currentname = "";
      this.currentid = cat_id
      for (var prop in this.goodslist) {
        if (cat_id === this.goodslist[prop].cat_id) {
          this.list.push(this.goodslist[prop])
        }
      }
      //  console.log("当前表", this.list);
      console.log('list', this.list)
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
    // 点击tree节点
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
