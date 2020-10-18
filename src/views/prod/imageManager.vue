<template>
  <div id="tagMain" class="app-container">
    <el-row :gutter="15">
      <el-col :span="16">
        <div class="grid-content bg-purple">
          <div id="todo-list-example">
            <form>
              <input
                id="new-todo"
                style="height:35px;magin-left:5px"
                placeholder=""
              >
              <button style="background:white;height:35px;border-radius:4px;border:1px solid;margin:10px" @click="openUpload()">画像アップロード</button>
              <el-divider />
            </form>
            <div v-if="imageList.length>0" class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td scope="col">画像Id</td>
                    <td scope="col">画像URL</td>
                  </tr>
                </thead>
                <draggable v-model="imageList" tag="tbody">
                  <tr v-for="item in imageList" :key="item.catimg_id">
                    <td scope="row">{{ item.catimg_id }}</td>
                    <td><el-link type="primary" @click="viewImage(item.catimg_path)">{{ item.catimg_path }}</el-link></td>
                    <td><i class="el-icon-delete" @click="deleteImg(item.catimg_id,item.cat_id)" /> </td>
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
            @node-click="handleNodeClick"
          />
          <!-- <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />-->
        </div>
      </el-col>
    </el-row>
    <el-dialog
      title="画像"
      :visible.sync="dialogVisible"
      width="50%"
    >
      <div id="imgbox" class="el-dialog-div" :style="{'background-image': 'url(' + 'http://13.112.112.160/shopping/upimg/' + imgPath + ')'}" />
    </el-dialog>
    <el-dialog
      title="画像を選択"
      :visible.sync="visibleComponent"
      width="50%"
      :before-close="handleClose"
    >
      <div>
        <input id="imageFile" type="file" accept="image/*" @change="setImage">
        <br>
        <table>
          <tr>
            <td v-if="imgSrc != ''" scope="col">元画像</td>
            <td scope="col" width="20px" />
            <td v-if="cropImg != ''" scope="col">トリミングした画像</td>
          </tr><tr /><tr>
            <td>
              <div v-if="imgSrc != ''" style="width: 400px; height:300px; border: 1px solid gray; display: inline-block;">
                <vue-cropper
                  ref="cropper"
                  :guides="true"
                  :view-mode="2"
                  drag-mode="crop"
                  :auto-crop-area="0.5"
                  :min-container-width="250"
                  :min-container-height="180"
                  :background="true"
                  :rotatable="false"
                  :src="imgSrc"
                  alt="Source Image"
                  :img-style="{ 'width': '400px', 'height': '300px' }"
                  :aspect-ratio="1"
                />
              </div>
            </td>
            <td />
            <td>
              <img v-if="cropImg != ''" :src="cropImg" alt="Cropped Image">
            </td>
          </tr>
        </table>
        <!-- <img
          :src="cropImg"
          style="width: 200px; height: 150px; border: 1px solid gray"
          alt="Cropped Image"
        >-->
        <br>
        <br>

        <button v-if="imgSrc != ''" style="margin-right: 40px;" @click="cropImage">トリミングする</button>
        <button v-if="imgSrc != ''" @click="saveImage">保存</button>
      </div>
    </el-dialog>
  </div>
</template>
<script>
import draggable from 'vuedraggable'
import VueCropper from 'vue-cropperjs'
import 'cropperjs/dist/cropper.css'
export default {
  name: 'CatManager',
  components: { draggable, VueCropper },
  data() {
    return {
      listall: [],
      list: [],
      defaultProps: {
        // children: 'children',
        label: 'cat_name'
      },
      catId: 0,
      imageList: [
        { catimg_id: '', catimg_path: '', cat_id: '' }
      ],
      dialogVisible: false,
      imgPath: '',
      visibleComponent: false,
      imgSrc: '',
      cropImg: ''
    }
  },
  mounted() {
    this.imageList = []
  },
  methods: {
    async  loadNode(node, resolve) {
      if (node.level === 0) {
        var req = {
          'mode': 'select',
          'selectsql': 'select cat_id, cat_name, parent_id from ns_cat'
        }
        await this.axios.post('http://13.112.112.160:8080/test/web.do', req).then((response) => {
          console.log(response.data)
          this.listall = response.data.data
        }).catch((response) => {
          console.log(response)
        })
        return resolve(this.getnode(0))
      }
      return resolve(this.getnode(node.data.cat_id))
    },
    getnode(parent_id) {
      var nlist = []
      for (var prop in this.listall) {
        if (parent_id === this.listall[prop].parent_id) { nlist.push(this.listall[prop]) }
      }
      return nlist
    },
    handleNodeClick(node, data, value) {
      if (node.parent_id !== 0) {
        console.log('node.cat_id:' + node.cat_id)
        this.getImagesList(node.cat_id)
      }
    },
    async getImagesList(cat_id) {
      this.imageList = []
      console.log('Image load start' + cat_id)
      // カタログと紐づく画像リストをDBから取得する
      var reqCat = {
        'mode': 'select',
        'selectsql': 'SELECT t.catimg_id,t.catimg_path,t.cat_id from ns_catimg t where (t.delflg is null or t.delflg <> 1) and t.cat_id =' + cat_id
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do', reqCat).then((response) => {
        console.log(response.data)
        if (response.data.data.length > 0) {
          this.imageList = response.data.data
          this.catId = cat_id
        }
      }).catch((response) => {
        console.log('Image Response failed' + response)
      })
    },
    viewImage(catimg_path) {
      this.dialogVisible = true
      this.imgPath = catimg_path
    },
    deleteImg(catimg_id, cat_id) {
      this.$confirm('画像を削除しますか?', '提示', {
        confirmButtonText: '削除する',
        cancelButtonText: 'キャンセルする',
        type: 'warning'
      }).then(() => {
        this.deleteSubmit(catimg_id)
        this.$message({
          type: 'success',
          message: '削除しました!'
        })
        this.getImagesList(cat_id)
      }).catch(() => {
      })
    },
    async deleteSubmit(catimg_id) {
      var reqUpdate = {
        'mode': 'update',
        'tableName': 'ns_catimg',
        'wheresql': 'catimg_id =' + catimg_id,
        'data': {
          'delflg': '1'
        }
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do', reqUpdate).then((response) => {
        console.log('Update success!')
        console.log(response.data)
      }).catch((response) => {
        console.log('Update error!' + response)
      })
    },
    openUpload() {
      console.log('open upload menu')
      console.log(this.catId)
      this.visibleComponent = true
    },
    setImage(e) {
      const file = e.target.files[0]
      if (!file.type.includes('image/')) {
        alert('Please select an image file')
        return
      }
      if (typeof FileReader === 'function') {
        const reader = new FileReader()
        reader.onload = event => {
          this.imgSrc = event.target.result
          // rebuild cropperjs with the updated source
          this.$refs.cropper.replace(event.target.result)
        }
        reader.readAsDataURL(file)
      } else {
        alert('Sorry, FileReader API not supported')
      }
    },
    cropImage() {
      // get image data for post processing, e.g. upload or setting image src
      this.cropImg = this.$refs.cropper.getCroppedCanvas().toDataURL()
    },
    saveImage() {
      // guess what this does :)
      this.$refs.cropper.rotate(90)
    },
    handleClose(done) {
      this.$confirm('画像アップロードやめますか')
        .then(_ => {
          this.imgSrc = ''
          this.cropImg = ''
          var obj = document.getElementById('imageFile')
          obj.value = ''
          done()
        })
        .catch(_ => {})
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
.el-dialog-div{
    height: 70vh;
    overflow: auto;
    background-repeat: no-repeat;
    background-size: 92% 92%;
}

</style>
