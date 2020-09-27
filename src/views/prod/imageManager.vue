<template>
<div>
  <div class="com-upload-img c-contentsArea__primaryCol">
    <div class="img_group grid-content bg-purple-light">
      <div v-if="allowAddImg" class="img_box">
        <input type="file" accept="image/*" multiple="multiple" @change="changeImg($event)">
        <div class="filter" />
      </div>
      <div v-for="(item,index) in imgArr" :key="index" class="img_box">
        <div class="img_show_box">
          <tr>
          <img :src="item" alt="">
          <td>删除</td>
          <i class="img_delete" @click="deleteImg(index)" />
          <!-- <i class="img_delete" @click="imgArr.splice(index,1)"></i> -->
          </tr>
        </div>
      </div>
    </div>
  </div>
  <div class = "c-contentsArea__secondaryCol">
   <div class="grid-content bg-purple-light">
    <el-tree :data="listData" :props="defaultProps" @node-click="handleNodeClick" />
   </div>
  </div>
  <div>
    <!-- レシビPOP -->
   <!--<imageUpload :show="show" :title="title" :rspid="rspid" @hidePop="hidePop" @submitPop="submitPop">
   </imageUpload>-->
  </div>
</div>
</template>

<script>
//import imageUpload from './imageUpload'

export default {
  name: 'ComUpLoad',
  data() {
    return {
      title: 'レシピ紹介',
      show: false,
      rspid:'',
      imgData: '',
      imgArr: [],
      imgSrc: '',
      allowAddImg: true,
      listData: [
        { id: 1, name: '調味料、ビン類', children:[{id:7, name:'醤油類'},{id:13, name:'油'}]},
        { id: 2, name: '野菜・くだもの', children:[{id:8, name:'根菜、芋類'},{id:14, name:'葉物'},{id:15, name:'サラダ菜'},{id:16, name:'香味野菜、きのこ'}]},
        { id: 3, name: '肉類', children:[{id:9, name:'豚肉'},{id:17, name:'鶏肉'}]},
        { id: 4, name: '飲み物', children:[{id:10, name:'牛乳'},{id:18, name:'野菜ジュース'}]},
      ],
      dragging: false,
      defaultProps: {
        children: 'children',
        label:'name'
      }
    }
  },
    components: {
        //imageUpload
  },
  methods: {
    changeImg: function(e) {
      var _this = this
      var imgLimit = 1024
      var files = e.target.files
      var image = new Image()
      if (files.length > 0) {
        var dd = 0
        var timer = setInterval(function() {
          if (files.item(dd).type !== 'image/png' && files.item(dd).type !== 'image/jpeg' && files.item(dd).type !== 'image/gif') {
            return false
          }
          if (files.item(dd).size > imgLimit * 102400) {
            // to do sth
          } else {
            image.src = window.URL.createObjectURL(files.item(dd))
            image.onload = function() {
              // 默认按比例压缩
              var w = image.width
              var h = image.height
              var scale = w / h
              w = 200
              h = w / scale
              // 默认图片质量为0.7，quality值越小，所绘制出的图像越模糊
              var quality = 0.7
              // 生成canvas
              var canvas = document.createElement('canvas')
              var ctx = canvas.getContext('2d')
              // 创建属性节点
              var anw = document.createAttribute('width')
              anw.nodeValue = w
              var anh = document.createAttribute('height')
              anh.nodeValue = h
              canvas.setAttributeNode(anw)
              canvas.setAttributeNode(anh)
              ctx.drawImage(image, 0, 0, w, h)
              var ext = image.src.substring(image.src.lastIndexOf('.') + 1).toLowerCase()// 图片格式
              var base64 = canvas.toDataURL('image/' + ext, quality)
              // 回调函数返回base64的值
              if (_this.imgArr.length <= 4) {
                _this.imgArr.unshift('')
                _this.imgArr.splice(0, 1, base64)// 替换数组数据的方法，此处不能使用：this.imgArr[index] = url;
                if (_this.imgArr.length >= 5) {
                  _this.allowAddImg = false
                }
              }
            }
          }
          if (dd < files.length - 1) {
            dd++
          } else {
            clearInterval(timer)
          }
        }, 1000)
      }
    },
    deleteImg: function(index) {
      this.imgArr.splice(index, 1)
      if (this.imgArr.length < 5) {
        this.allowAddImg = true
      }
    },
    handleNodeClick(data) {
      console.log(data)
    },
    hideSubPop() {
      // 取消弹窗回调
      this.gdsitmshow = false
    },
    submitSubPop() {
      // 确认弹窗回调
      this.gdsitmshow = false
    }
  }
}
</script>
<style>
.c-contentsArea__secondaryCol {
    display: table-cell;
    width: 350px;
    vertical-align: top;
}
.c-contentsArea__primaryCol {
    display: table-cell;
    vertical-align: top;
}
.teatree {
  cursor: pointer;
  height: 100%;
  overflow: hidden;
}

.teatree-node {
  padding-right: 0.25rem;
}

.teatree-node-item {
  display: flex;
  align-items: center;
  height: 1.5rem;
  background: transparent;

  /* hack to make hover the full width of parent */
  padding-left: 100%;
  margin-left: -100%;
  padding-right: 100%;
  margin-right: -100%;
}

.teatree-node-item:hover {
  background-color: #718096;
}

.teatree-node-item-selected {
  background-color: #718096;
}

.teatree-node-item-name-padded-leaf {
  padding-left: 1.25rem;
}
</style>