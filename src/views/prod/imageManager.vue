<template>
  <div id="tagMain" class="app-container">
    <el-row :gutter="15">
      <el-col :span="16">
        <div class="grid-content bg-purple">
          <div id="todo-list-example">
            <button
              style="
                background: white;
                height: 35px;
                border-radius: 4px;
                border: 1px solid;
                margin: 10px;
              "
              :disabled="leafFlag == '0'"
              @click="openUpload()"
            >
              画像アップロード
            </button>
            <div v-if="imageList.length > 0" class="row">
              <table class="table-striped">
                <thead class="thead-dark">
                  <tr>
                    <td scope="col">画像Id</td>
                    <td scope="col">画像カテゴリ名</td>
                  </tr>
                </thead>
                <draggable v-model="imageList" tag="tbody">
                  <tr v-for="item in imageList" :key="item.catimg_id">
                    <td scope="row">{{ item.catimg_id }}</td>
                    <td>
                      <el-link
                        type="primary"
                        @click="viewImage(item.catimg_path)"
                      >{{ item.catname }}</el-link>
                    </td>
                    <td>
                      <div
                        :style="{
                          width: '100px',
                          height: '100px',
                          'background-image':
                            'url(' +
                            $webUrl +
                            '/shopping/upimg/' +
                            item.catimg_mini +
                            ')',
                        }"
                      />
                    </td>
                    <td>
                      <i
                        class="el-icon-delete"
                        @click="deleteImg(item.catimg_id, item.cat_id)"
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
            :props="defaultProps"
            :load="loadNode"
            lazy
            @node-click="handleNodeClick"
          />
          <!-- <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />-->
        </div>
      </el-col>
    </el-row>
    <el-dialog title="画像" :visible.sync="dialogVisible" width="50%">
      <div
        id="imgbox"
        class="el-dialog-div"
        :style="{
          'background-image':
            'url(' + this.$webUrl + '/shopping/upimg/' + imgPath + ')',
        }"
      />
    </el-dialog>
    <el-dialog
      title="画像を選択"
      :visible.sync="visibleComponent"
      width="870px"
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
          </tr>
          <tr />
          <tr>
            <td>
              <div
                v-if="imgSrc != ''"
                style="
                  width: 400px;
                  height: 300px;
                  border: 1px solid gray;
                  display: inline-block;
                "
              >
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
                  :img-style="{ width: '400px', height: '300px' }"
                  :aspect-ratio="1.3333"
                />
              </div>
            </td>
            <td />
            <td>
              <img
                v-if="cropImg != ''"
                :src="cropImg"
                alt="Cropped Image"
                height="300"
                width="400"
              >
            </td>
          </tr>
        </table>
        <br>
        <br>

        <button
          v-if="imgSrc != ''"
          style="margin-right: 40px"
          @click="cropImage"
        >
          トリミングする
        </button>
        <button v-if="cropImg != ''" id="submit" @click="saveImage">
          保存
        </button>
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
      leafFlag: '0',
      imageList: [
        {
          catimg_id: '',
          catimg_path: '',
          catimg_mini: '',
          cat_id: '',
          cat_name: '',
          catname: ''
        }
      ],
      imageListTemp: [
        {
          catimg_id: '',
          catimg_path: '',
          catimg_mini: '',
          cat_id: '',
          cat_name: '',
          catname: ''
        }
      ],
      dialogVisible: false,
      imgPath: '',
      childrenlist: [
        { cat_id: '' }
      ],
      visibleComponent: false,
      imgSrc: '',
      cropImg: '',
      uploadFile: null,
      filePath: '',
      filePathMini: '',
      filename: '',
      i: 0,
      catname: ''
    }
  },
  mounted() {
    this.imageList = []
  },
  methods: {
    async loadNode(node, resolve) {
      if (node.level === 0) {
        var req = {
          mode: 'select',
          selectsql:
            'select cat_id, cat_name, parent_id, leaf_flag from ns_cat where delflg is null or delflg <> 1'
        }
        await this.axios
          .post(this.$baseUrl + '/web.do', req)
          .then((response) => {
            console.log(response.data)
            this.listall = response.data.data
          })
          .catch((response) => {
            console.log(response)
          })
        return resolve(this.getnode(0))
      }
      return resolve(this.getnode(node.data.cat_id))
    },
    getnode(parent_id) {
      var nlist = []
      for (var prop in this.listall) {
        if (parent_id === this.listall[prop].parent_id) {
          nlist.push(this.listall[prop])
        }
      }
      return nlist
    },
    handleNodeClick(node, data, value) {
      this.imageList = []
      if (node.leaf_flag === 0) {
        console.log('node.cat_id:' + node.cat_id)
        this.getAllChildrenId(node.cat_id)
      } else {
        this.getImagesList(node.cat_id)
      }
      this.leafFlag = node.leaf_flag
    },
    async getAllChildrenId(cat_id) {
      var req = {
        'mode': 'select',
        'selectsql': 'select cat_id from ( select t1.cat_id,if(find_in_set(parent_id, @pids) > 0, @pids := concat(@pids, \',\', cat_id), 0) as ischild from (select cat_id,parent_id from ns_cat t where (delflg is null or delflg <> 1) order by parent_id, cat_id ) t1,(select @pids := ' + cat_id + ') t2) t3 where ischild != 0'
      }
      await this.axios.post(this.$baseUrl + '/web.do', req).then((response) => {
        console.log('childrenList')
        this.childrenlist = response.data.data
        console.log(this.childrenlist)
        for (var i in this.childrenlist) {
          this.getImagesList(this.childrenlist[i].cat_id)
        }
      }).catch((response) => {
        console.log(response)
      })
    },
    async getImagesList(cat_id) {
      this.imageListTemp = []
      console.log('Image load start' + cat_id)
      // カタログと紐づく画像リストをDBから取得する
      var reqCat = {
        mode: 'select',
        selectsql:
          'SELECT t.catimg_id,t.catimg_path,t.catimg_mini,t.cat_id, c.cat_name from ns_catimg t left join ns_cat c on t.cat_id = c.cat_id where (t.delflg is null or t.delflg <> 1) and t.cat_id =' +
          cat_id
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqCat)
        .then((response) => {
          console.log(response.data)
          if (response.data.data.length > 0) {
            this.imageListTemp = response.data.data
            for (var i = 0; i < this.imageListTemp.length; i++) {
              this.imageListTemp[i].catname = this.imageListTemp[i].cat_name + (i + 1)
              console.log('catname:', this.imageListTemp)
            }
          }
          console.log('I am here')
          this.catId = cat_id
          for (var j in this.imageListTemp) {
            this.imageList.push(this.imageListTemp[j])
          }
          console.log('I am there')
        })
        .catch((response) => {
          console.log('Image Response failed' + response)
        })
      console.log('list长度：', this.imageList.length)
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
      })
        .then(() => {
          this.deleteSubmit(catimg_id)
          this.$message({
            type: 'success',
            message: '削除しました!'
          })
          this.getImagesList(cat_id)
          this.imageList = this.imageListTemp
        })
        .catch(() => {})
    },
    async deleteSubmit(catimg_id) {
      var reqUpdate = {
        mode: 'update',
        tableName: 'ns_catimg',
        wheresql: 'catimg_id =' + catimg_id,
        data: {
          delflg: '1'
        }
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqUpdate)
        .then((response) => {
          console.log('Update success!')
          console.log(response.data)
        })
        .catch((response) => {
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
      this.filename = file.filename
      if (!file.type.includes('image/')) {
        alert('Please select an image file')
        return
      }
      this.imgSrc = ''
      if (typeof FileReader === 'function') {
        const reader = new FileReader()
        reader.onload = (event) => {
          this.imgSrc = event.target.result
          // rebuild cropperjs with the updated source
          // this.$refs.cropper.replace(event.target.result)
        }
        reader.readAsDataURL(file)
      } else {
        alert('Sorry, FileReader API not supported')
      }
    },
    cropImage() {
      // get image data for post processing, e.g. upload or setting image src
      this.cropImg = this.$refs.cropper.getCroppedCanvas().toDataURL()
      this.dataURLtoFile(this.cropImg, this.filename)
      console.log('cropImg cropImg cropImg')
      console.log(this.cropImg)
    },
    async saveImage() {
      // guess what this does :)
      // this.$refs.cropper.rotate(90)
      document.getElementById('submit').disabled = true
      const formData = new FormData()
      formData.append('file', this.uploadFile)
      await this.axios
        .post(this.$baseUrl + '/cat-upload.do', formData)
        .then((response) => {
          console.log('Upload success!')
          console.log(response.data)
          this.filePath = response.data.catimg_path
          this.filePathMini = response.data.catimg_mini
          console.log(this.filePath)
          console.log(this.filePathMini)
          this.visibleComponent = false
          this.registerImgDb()
        })
        .catch((response) => {
          console.log('Upload error!' + response)
        })
    },
    handleClose(done) {
      this.$confirm('画像アップロードやめますか')
        .then((_) => {
          this.imgSrc = ''
          this.cropImg = ''
          var obj = document.getElementById('imageFile')
          obj.value = ''
          done()
        })
        .catch((_) => {})
    },
    async registerImgDb() {
      // ns_catimgテーブルに登録
      console.log('Insert into catming DB')
      var reqInsertCatimg = {
        mode: 'insert',
        tableName: 'ns_catimg',
        autofield: 'xxx',
        data: {
          catimg_path: this.filePath,
          catimg_mini: this.filePathMini,
          cat_id: this.catId
        }
      }
      await this.axios
        .post(this.$baseUrl + '/web.do', reqInsertCatimg)
        .then((response) => {
          console.log('Insert success!')
          console.log(response.data)
          this.imgSrc = ''
          this.cropImg = ''
          var obj = document.getElementById('imageFile')
          obj.value = ''
          this.getImagesList(this.catId)
          this.imageList = this.imageListTemp
        })
        .catch((response) => {
          console.log('Insert error!' + response)
        })
      this.$message({
        type: 'success',
        message: '保存しました!'
      })
    },
    // base64转file
    dataURLtoFile(dataurl, filename) {
      var arr = dataurl.split(',')
      var mime = arr[0].match(/:(.*?);/)[1]
      var bstr = atob(arr[1])
      var n = bstr.length
      var u8arr = new Uint8Array(n)
      while (n--) {
        u8arr[n] = bstr.charCodeAt(n)
      }
      this.uploadFile = new File([u8arr], filename, { type: mime })
    }
  }
}
</script>

<style>
.app-container {
  overflow: auto;
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
  height: 380px;
  padding-left: 15px;
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
  overflow: auto;
  height: 600px;
  min-height: 36px;
}
.row-bg {
  padding: 10px 0;
  background-color: eff0f4;
}
.table-striped thead th {
  overflow: auto;
  background-color: #ffffff;
  color: #000000;
  border-bottom-width: 0;
}

/* Column Style */
.table-striped td {
  overflow: auto;
  color: #000;
  border-collapse: collapse;
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
.el-dialog-div {
  height: 70vh;
  overflow: auto;
  background-repeat: no-repeat;
  background-size: 92% 92%;
}
</style>
