<template>
    <div class="app-container" id="tagMain">
      <div class="setMain">
        <div style="width:75%">
          <!--<img id="prod" :src="'http://13.112.112.160/shopping/upimg/'+imageList[current].catimg_path" alt=""  width="100%" >-->
          <div id="imgbox" class="imgbox" :style="{'background-image': 'url(' + 'http://13.112.112.160/shopping/upimg/' + imageList[current].catimg_path + ')'}" v-show="showFlag">
            <VueDragResize  @dragstop="onDragstopExist($event,lbl.index)"  :x="imgwidth*lbl.lbl_pst_x" :y="imgheight * lbl.lbl_pst_y" :w="120" :h="80" :isResizable="false" 
             v-for="(lbl, key) in curLbls" :key="key">
             <div v-if="lbl.delflg==null">
             <img :src="tagimg"  @contextmenu.prevent="onContextmenuExist($event,lbl.index)"  alt="" class="tags" draggable="false" οndragstart="return false">
             <span class="fl" @contextmenu.prevent="onContextmenuExist($event,lbl.index)" >{{lbl.goods_name}}</span>
             </div>
            </VueDragResize>
          </div>
          <div v-show="showFlag == false">{{ msg }} </div>
        </div>
        <div style="width:28%">
          <div style="height:70%">
            <div class="grid-content bg-purple-light">
              <el-tree
              :props="defaultProps"
              :load="loadNode"
              lazy
              @node-click="handleNodeClick"
            />
            </div>
          </div>
          <div style="height:30%">
            <div class="center_btn" v-show="showFlag">
              <el-button-group>
                <el-button @click="pre" type="primary" icon="el-icon-arrow-left">前へ</el-button>
                <el-button @click="next" type="primary">次へ<i class="el-icon-arrow-right el-icon--right"></i></el-button>
              </el-button-group>
            </div>
            <el-form ref="imageList[current]" :model="imageList[current]" label-width="100px" v-show="showFlag">

              <el-form-item label="売り場名">
                <el-input v-model="imageList[current].cat_name"></el-input>
              </el-form-item>
              <el-form-item label="公表">
                <el-switch v-model="imageList[current].publish"></el-switch>
              </el-form-item>
               <el-form-item>
              <el-button type="success" @click="addTag">タグ追加</el-button>
              </el-form-item>
              <el-form-item>
                 <el-button type="warning" @click="onSubmit('this')">確認する</el-button>
              </el-form-item>
            </el-form>
          </div>
        </div>
      </div>
      <VueDragResize   @dragstop="onDragstop($event,item.index)" :x="item.left+20" :y="item.top+20" :w="120" :h="80" :isResizable="false" v-for="(item,key) in newlist" :key="key" >
         <div v-if="item.delflg==null">
         <img :src="tagimg"  @contextmenu.prevent="onContextmenu($event,item.index)"  alt="" class="tags" draggable="false" οndragstart="return false">
         <span class="fl" @contextmenu.prevent="onContextmenu($event,item.index)" >{{item.goods_name}}</span>
         </div>
      </VueDragResize>
      <el-dialog
        title="タグ編集"
        :visible.sync="dialogVisible"
        width="30%"
        :before-close="handleClose">
        <input type="hidden" v-bind:value="currentTag"/>
          <el-select
            style="width:100%"
            placeholder="商品名"
            suffix-icon="el-icon-tickets"
            @change="selectChanged"
            v-model="prodId">
            <el-option v-for="item in goodsList" :key="item.goods_id" :label="item.goods_name" :value="item.goods_id"></el-option>
          </el-select>
          <p></p>
        <span slot="footer" class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="updateProd">確 認</el-button>
        </span>
      </el-dialog>

  </div>
</template>

<script>
import tag from '@/assets/images/tag.gif'
import VueDragResize from 'vue-drag-resize';
export default {
  name:'priceSetting',
  components:{VueDragResize},
  data(){
    return {
      // list‐新規用タグ情報
      newlist:[],
      // updateList‐更新用タグ情報
      updateList:[],
      // imageList‐カタログと紐づく画像リスト
      imageList:[
        {catimg_path:'',cat_name:'',tags:[],publish:false,}
      ],
      // catList‐カタログツリーリスト
      catList: [
        { cat_id: 1, cat_name: 'xxx', parent_id: 0 }
      ],
      // lbls‐既存カタログと紐づくタグリスト（DBから取得）
      lbls:[{lbl_id:0,catimg_id:0,goods_id:0,lbl_pst_x:0,lbl_pst_y:0,cat_id:0,goods_name:'',delflg:null}],
      // curLbls-lblsリストから特定画像と紐づく既存タグリスト
      curLbls:[],
      // goodsList-カタログと紐づく商品リスト（DBから取得）
      goodsList:[{goods_id:1, goods_name:'abc', cat_id:2}],
      // 現在の画像順
      current:0,
      defaultProps: {
        label: 'cat_name',
        isLeaf: 'leaf'
      },
      tagimg:tag,
      dialogVisible: false,
      currentTag:'',
      currentLblId:'',
      sanchi:'',
      price:'',
      prodName:'', 
      prodId:'',     
      ty:'',
      showFlag:false,
      imgheight:600,
      imgwidth:800,
      x:'',
      y:'',
      msg :'No image',
    }
  },
  mounted:function(){
  },
  methods:{
    async loadNode(node, resolve) {
      console.log('loadNode start')
      if (node.level === 0) {
        var req = {
          "mode":"select",
          "selectsql":"select cat_id, cat_name, parent_id from ns_cat"
        }
        await this.axios.post('http://13.112.112.160:8080/test/web.do',req).then((response)=>{
          console.log(response.data)
          this.catList = response.data.data
        }).catch((response)=>{
          console.log(response);
        })
        return resolve(this.getnode(0))
      }
      return resolve(this.getnode(node.data.cat_id))
    },
    getnode(parentid) {
      var nlist = []
      for (var prop in this.catList) {
        if (parentid === this.catList[prop].parent_id) { nlist.push(this.catList[prop]) }
      }
      return nlist
    },    
    handleNodeClick(node,data,value) {
      if(node.parent_id !== 0 ){
          console.log("node.cat_id:" + node.cat_id)
          this.getImagesList(node.cat_id)
      } 
      this.newlist = []
      this.updateList = []
    },
    async getImagesList(cat_id){
      console.log('Image load start'+cat_id)
      //カタログと紐づく画像リストをDBから取得する
      var reqCat = {
          "mode":"select",
          "selectsql":"SELECT ns_catimg.catimg_id, ns_catimg.catimg_path, "+
          "ns_catimg.cat_id, ns_cat.cat_name from ns_catimg left join ns_cat on ns_catimg.cat_id = ns_cat.cat_id where ns_cat.cat_id =" + cat_id
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do',reqCat).then((response)=>{
        console.log(response.data)
        if(response.data.data.length>0){
          this.imageList = response.data.data
          this.showFlag = true
        }else{
          this.showFlag = false
        }
      }).catch((response)=>{
        console.log('Image Response failed'+response);
      })
      // カタログと紐づく商品リストをDBから取得する
      this.goodsList = [];
      var reqGoods =  {
          "mode":"select",
          "selectsql":"select goods_id,goods_name,cat_id from ns_goods where delflg is null and cat_id =" + cat_id
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do',reqGoods).then((response)=>{
        console.log('Goods list get');
        console.log(response.data)
        this.goodsList = response.data.data
      }).catch((response)=>{
        console.log("Homepage setInit get ns_lbl error!" + response);
      })
      // カタログと紐づくタグリストをDBから取得する
      this.lbls = [];
      var sqlTag = "select a.lbl_id,a.catimg_id,a.goods_id,a.lbl_pst_x,a.lbl_pst_y,c.cat_id"
      sqlTag += ",g.goods_name,a.delflg"
      sqlTag += " from ns_lbl a"
      sqlTag += " left join ns_catimg c on c.catimg_id = a.catimg_id"
      sqlTag += " left join ns_goods g on g.goods_id = a.goods_id"
      sqlTag += " where c.cat_id = " + cat_id
      var reqTag = {
        "mode":"select",
        "selectsql":sqlTag
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do',reqTag).then((response)=>{
        console.log(response.data)
        this.lbls = response.data.data
      }).catch((response)=>{
        console.log("Homepage setInit get ns_lbl error!" + response);
      })
      var imgbox=document.getElementById("imgbox");
      console.log("imgbox.clientHeight:" + imgbox.clientHeight)
      console.log("imgbox.clientWidth:" + imgbox.clientWidth)
      this.imgheight=imgbox.clientHeight;
      this.imgwidth=imgbox.clientWidth;
      this.getCurLbls()
    },
    // 特定画像と紐づく既存タグリストを取得
    getCurLbls(){
      this.newlist = []
      this.updateList = []
      console.log("getCurLbls, this.lbls.length:" + this.lbls.length)
      console.log(this.lbls)
      this.curLbls = []
      var index = 0
      var arry = []
      for(var i in this.lbls){
        if(this.lbls[i].catimg_id == this.imageList[this.current].catimg_id){
          //console.log("getCurLbls add lbl")
          console.log("getCurLbls add lblthis.current"+this.current)
          var j = i
          arry = JSON.parse(JSON.stringify(this.lbls[i])); 
          arry.index = index++
          console.log("array")
          console.log(arry)
          this.curLbls.push(arry)
        }  
      }
      console.log("curLbls")
      console.log(this.curLbls)
    },
    pre(){  
      if(this.newlist.length>0 || this.updateList.length>0) {
        this.onSubmit('pre') 
      }else{
        if(this.current<=0){
        this.current=0
        }else{
        this.current--;
        } 
        this.getCurLbls()
      }
      console.log("this.current"+this.current)
    },
    next(){
      if(this.newlist.length>0 || this.updateList.length>0) {
        this.onSubmit('next') 
      }else{
        if(this.current>=this.imageList.length-1){
          this.current=this.imageList.length-1
        }else{
          this.current++;
        }
        this.getCurLbls()
      }
      console.log("this.current"+this.current)
    },
    onSubmit(flag) {
      //console.log(this.imageList[this.current].tags[0].top);
      this.$confirm('タグを更新しますか?', '提示', {
          confirmButtonText: '確認する',
          cancelButtonText: 'キャンセルする',
          type: 'warning'
        }).then(() => {
          this.dataSubmit(flag)
          this.$message({
            type: 'success',
            message: '更新しました!'
          });
        }).catch(() => {
          if(flag=='pre'){
            if(this.current<=0){
              this.current=0
            }else{
              this.current--;
            } 
            this.getCurLbls()
          }else if(flag=='next'){
            if(this.current>=this.imageList.length-1){
              this.current=this.imageList.length-1
            }else{
              this.current++;
            }
            this.getCurLbls()
          }
          this.$message({
            type: 'info',
            message: 'キャンセルしました'
          });          
        });
    },
    addTag(){
      var item={};
      item.price='';
      item.left=0;
      item.top=0;
      //item.sanchi=''
      item.goods_id=''
      item.goods_name =''
      item.x='';
      item.y='';
      item.delflg=null
      //item.ty="";
      item.index=this.newlist.length;
      item.catimg_id=this.imageList[this.current].catimg_id
      this.newlist.push(item);
    },
    onDragstop(event,index){
       var prod=document.getElementById('imgbox');
       console.log("eventTop"+event.top+"index"+index+"list.size=="+this.newlist.length)
       this.newlist[index].top=event.top-20;
       this.newlist[index].left=event.left-20;
       this.newlist[index].x=this.newlist[index].left/prod.clientWidth;
       this.newlist[index].y=this.newlist[index].top/prod.clientHeight;
    },
    onDragstopExist(event,index){
       var prod=document.getElementById('imgbox');
       console.log("eventTop"+event.top+"index"+index+"list.size=="+this.newlist.length)
       //this.newlist[index].top=event.top-20;
       //this.newlist[index].left=event.left-20;
       var newData =true
       this.curLbls[index].lbl_pst_x=(event.left-20)/prod.clientWidth;
       this.curLbls[index].lbl_pst_y=(event.top-20)/prod.clientHeight;
       for(var j in this.updateList){
          if(this.updateList[j].lbl_id==this.curLbls[index].lbl_id){
              newData =false
              this.updateList[index].lbl_pst_x =(event.left-20)/prod.clientWidth;
              this.updateList[index].lbl_pst_y =(event.top-20)/prod.clientHeight;
              break
          }
        }
        //updateListに存在しない場合
        if(newData){
          this.updateList.push(this.curLbls[index])
        }
    },
    onContextmenu(event,index){
      let id=index;
      this.$contextmenu({
        items: [
          {
            label: "タグ編集",
            onClick: () => {
              //console.log("currentTag=="+goodName+" "+goodId);
              this.currentTag=id
              this.dialogVisible=true
              this.currentLblId=''
              this.prodId=this.newlist[id].goods_id
              this.prodName=this.newlist[id].goods_name
            }
          },
          {
            label: "タグ削除",
            onClick: () => {
              var arr=[]
              for(var i in this.newlist){
               // if(i!=index){
              //    if(i>index){
               //     this.newlist[i].index-1;
               //     arr.push(this.newlist[i])
              //    }else{
               //     arr.push(this.newlist[i])
               //   }
                //}
                if(i==index){
                  this.newlist[i].delflg=1
                }
              }
              //this.newlist=arr;
            }
          },
        ],
        event,
        //x: event.clientX,
        //y: event.clientY,
        zIndex: 3,
        minWidth: 230
      });
      return false;
    },
    handleClose(done) {
      this.$confirm('閉じますか')
        .then(_ => {
          done();
        })
        .catch(_ => {});
    },
    updateProd(){
      //this.imageList[this.current].tags[this.currentTag].sanchi=this.sanchi;
      //this.imageList[this.current].tags[this.currentTag].price=this.price;
      //this.imageList[this.current].tags[this.currentTag].prodname=this.prodname;
      //this.imageList[this.current].tags[this.currentTag].ty=this.ty;
      this.dialogVisible=false;
      console.log("prodId=="+this.prodId+" prodName=="+this.prodName)
      if(this.currentLblId==''){
        //新規登録の場合
        this.newlist[this.currentTag].goods_id = this.prodId
        this.newlist[this.currentTag].goods_name = this.prodName
      }else{
        //更新の場合
        var newData = true
        this.curLbls[this.currentTag].goods_id = this.prodId
        this.curLbls[this.currentTag].goods_name = this.prodName
        //updateListに既に存在する場合
        for(var j in this.updateList){
          if(this.updateList[j].lbl_id==this.curLbls[this.currentTag].lbl_id){
            newData =false
            this.updateList[j].goods_id = this.prodId
            this.updateList[j].goods_name = this.prodName
            break
          }
        }
        //updateListに存在しない場合
        if(newData){
          this.updateList.push(this.curLbls[this.currentTag])
        } 
      }
   },
    onContextmenuExist(event,index){
      let id=index;
      this.$contextmenu({
        items: [
          {
            label: "タグ編集",
            onClick: () => {
              //console.log("currentTag=="+goodName+" "+goodId);
              this.currentTag=id
              this.dialogVisible=true
              this.currentLblId=this.curLbls[id].lbl_id
              this.prodId=this.curLbls[id].goods_id
              this.prodName=this.curLbls[id].goods_name
            }
          },
          {
            label: "タグ削除",
            onClick: () => {
              var arr=[]
              var newData =true
              console.log("index"+index)
              for(var i=0;i<this.curLbls.length;i++){
                if(i==index){
                  this.curLbls[i].delflg=1
                  //updateListに既に存在する場合
                  for(var j in this.updateList){
                    if(this.updateList[j].lbl_id==this.curLbls[i].lbl_id){
                      newData =false
                      this.updateList[j].delflg =1
                      break
                    }
                  }
                  //updateListに存在しない場合
                  if(newData){
                    this.updateList.push(this.curLbls[i])
                  }
                  break
                }
              }
              console.log("curLbls" + this.curLbls.length);
              console.log(this.curLbls);
              console.log(this.updateList);
            }
          },
        ],
        event,
        //x: event.clientX,
        //y: event.clientY,
        zIndex: 3,
        minWidth: 230
      });
      return false;
    },
    selectChanged(value){
      this.prodId=value
      for(var i in this.goodsList){
        //console.log("check goodName"+value)
        //console.log(i)
        if(this.goodsList[i].goods_id == value){
          this.prodName=this.goodsList[i].goods_name
          break
        }
      }
    },
    async dataSubmit(flag){
      for(var i in this.newlist){
        if(this.newlist[i].goods_id==''){
          continue
        }
        console.log(this.newlist[i].catimg_id)
        console.log(this.newlist[i].goods_id)
        console.log(this.newlist[i].x)
        console.log(this.newlist[i].y)
        var reqInsert =  {
          "mode":"insert",
          "tableName":"ns_lbl",
          "autofield":"xxx",
          "data":{
            "catimg_id":this.newlist[i].catimg_id,
            "goods_id":this.newlist[i].goods_id,
            "lbl_pst_x":this.newlist[i].x,
            "lbl_pst_y":this.newlist[i].y,
          }
        }
        await this.axios.post('http://13.112.112.160:8080/test/web.do',reqInsert).then((response)=>{
        console.log("Insert success!")
        console.log(response.data)
        }).catch((response)=>{
        console.log("Insert error!" + response);
        })
      }
      for(var j in this.updateList){
        console.log(this.updateList[j].lbl_id)
        console.log(this.updateList[j].catimg_id)
        console.log(this.updateList[j].goods_id)
        console.log(this.updateList[j].delflg)
        var reqUpdate=  {
          "mode":"update",
          "tableName":"ns_lbl",
          "wheresql":"lbl_id =" + this.updateList[j].lbl_id,
          "data":{
            "goods_id":this.updateList[j].goods_id,
            "delflg":this.updateList[j].delflg,
            "lbl_pst_x":this.updateList[j].lbl_pst_x,
            "lbl_pst_y":this.updateList[j].lbl_pst_y,
          }
        }
        await this.axios.post('http://13.112.112.160:8080/test/web.do',reqUpdate).then((response)=>{
        console.log("Update success!")
        console.log(response.data)
        }).catch((response)=>{
        console.log("Update error!" + response);
        })
      }
      // カタログと紐づくタグリストをDBから取得する
      this.lbls = [];
      var sqlTag = "select a.lbl_id,a.catimg_id,a.goods_id,a.lbl_pst_x,a.lbl_pst_y,c.cat_id"
      sqlTag += ",g.goods_name,a.delflg"
      sqlTag += " from ns_lbl a"
      sqlTag += " left join ns_catimg c on c.catimg_id = a.catimg_id"
      sqlTag += " left join ns_goods g on g.goods_id = a.goods_id"
      sqlTag += " where c.cat_id = " + this.imageList[this.current].cat_id
      var reqTag = {
        "mode":"select",
        "selectsql":sqlTag
      }
      await this.axios.post('http://13.112.112.160:8080/test/web.do',reqTag).then((response)=>{
        console.log(response.data)
        this.lbls = response.data.data
      }).catch((response)=>{
        console.log("Homepage setInit get ns_lbl error!" + response);
      })
      if(flag=='pre'){
        if(this.current<=0){
          this.current=0
        }else{
          this.current--;
        } 
            
      }else if(flag=='next'){
        if(this.current>=this.imageList.length-1){
          this.current=this.imageList.length-1
        }else{
          this.current++;
        }
      }
      this.getCurLbls();
    },
  }
}
</script>

<style>
.setMain{
  display: flex;

}
.tags{
  height: 80px;
  width: 120px;
}
.center_btn{
  display:flex;
  justify-content: center;
  margin-bottom: 20px;
}
.fl{
  position:absolute;
  left:40px;
  top:30px ;
  z-index: 3;
}
.imgbox{
  height: 100%;
  width: 75%;
  position:absolute;
  margin:0 auto;
  background-repeat: no-repeat;
  background-size: 92% 92%;
}
.goodslbl{
    background-image: url('../../assets/images/tag.gif');
    background-repeat: no-repeat;
    background-size: 100% 100%;
    position:absolute;
    width:120px;
    height:80px;
    opacity:0.9;
    display:table-cell;
}
.lblfont{
  font-size: 9px;
}
</style>
