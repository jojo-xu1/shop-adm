<template>
    <div class="app-container" id="tagMain">
      <div class="setMain">
        <div style="width:80%">
          <img id="prod" :src="imageList[current].src" alt=""  width="100%">
        </div>
        <div style="width:20%">
            <div class="center_btn">
              <el-button-group>
                <el-button @click="pre" type="primary" icon="el-icon-arrow-left">前へ</el-button>
                <el-button @click="next" type="primary">次へ<i class="el-icon-arrow-right el-icon--right"></i></el-button>
              </el-button-group>
            </div>
            <el-form ref="imageList[current]" :model="imageList[current]" label-width="100px">

              <el-form-item label="売り場名">
                <el-input v-model="imageList[current].name"></el-input>
              </el-form-item>
              <el-form-item label="公表">
                <el-switch v-model="imageList[current].publish"></el-switch>
              </el-form-item>
               <el-form-item>
              <el-button type="success" @click="addTag">タグ追加</el-button>
              </el-form-item>
              <el-form-item>
                 <el-button type="warning" @click="onSubmit">確認する</el-button>
              </el-form-item>
            </el-form>

        </div>
      </div>
      <VueDragResize   @dragstop="onDragstop($event,item.index)" :x="item.left+20" :y="item.top+20" :w="120" :h="80" :isResizable="false"  v-for="(item,key) in imageList[current].tags" :key="key">
         <img :src="tagimg"  @contextmenu.prevent="onContextmenu($event,item.index)"  alt="" class="tags" draggable="false" οndragstart="return false">
         <span class="fl" @contextmenu.prevent="onContextmenu($event,item.index)" >{{item.price!=''?(item.price+'/'):''}}{{item.ty}}</span>
      </VueDragResize>
      <el-dialog
        title="タグ編集"
        :visible.sync="dialogVisible"
        width="30%"
        :before-close="handleClose">
        <input type="hidden" v-bind:value="currentTag"/>
          <el-input
            placeholder="商品名"
            suffix-icon="el-icon-tickets"
            v-model="prodname">
          </el-input>
          <p></p>
          <el-input
            placeholder="産地"
            suffix-icon="el-icon-location-outline"
            v-model="sanchi">
          </el-input>
          <p></p>
          <el-input
            placeholder="価格"
            suffix-icon="el-icon-goods"
            v-model="price">
          </el-input>
           <p></p>
           <el-input
            placeholder="単位"
            suffix-icon="el-icon-price-tag"
            v-model="ty">
          </el-input>
        <span slot="footer" class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="updateProd">確 認</el-button>
        </span>
      </el-dialog>

  </div>
</template>

<script>
import c from '@/assets/images/c.jpg'
import f from '@/assets/images/f.jpg'
import f1 from '@/assets/images/f1.jpg'
import g from '@/assets/images/g.jpg'
import h from '@/assets/images/h.jpg'
import j from '@/assets/images/j.jpg'
import q from '@/assets/images/q.jpg'
import tag from '@/assets/images/tag.gif'
import VueDragResize from 'vue-drag-resize';
export default {
  name:'priceSetting',
  components:{VueDragResize},
  data(){
    return {
      imageList:[{
        id:'1',src:c,name:'調味料',tags:[],publish:false,
      },
      {
        id:'2',src:f,name:'売り場1',tags:[],publish:true,
      },
      {
        id:'3',src:f1,name:'売り場2',tags:[],publish:true,
      },
      {
        id:'4',src:g,name:'売り場3',tags:[],publish:true,
      },
      {
        id:'5',src:h,name:'売り場4',tags:[],publish:true,
      },
      {
        id:'6',src:j,name:'売り場5',tags:[],publish:true,
      },
      {
        id:'7',src:q,name:'売り場6',tags:[],publish:true,
      },
      ],
      current:0,
      tagimg:tag,
      dialogVisible: false,
      currentTag:'',
      sanchi:'',
      price:'',
      prodname:'',
      ty:'',
    }
  },
  mounted(){
  },
  methods:{
    pre(){
      if(this.current<=0){
        this.current=0
      }else{
        this.current--;

      }
    },
    next(){
      if(this.current>=this.imageList.length-1){
        this.current=this.imageList.length-1
      }else{
        this.current++;
      }
    },
    onSubmit() {
        console.log(this.imageList[this.current].tags[0].top);
    },
    addTag(){

      var item={};
      item.price='';
      item.left=0;
      item.top=0;
      item.sanchi="";
      item.prodname=""
      item.x="";
      item.y="";
      item.ty="";
      item.index=this.imageList[this.current].tags.length;
      this.imageList[this.current].tags.push(item);
    },
    onDragstop(event,index){
        var prod=document.getElementById('prod');
       this.imageList[this.current].tags[index].top=event.top-20;
       this.imageList[this.current].tags[index].left=event.left-20;
       this.imageList[this.current].tags[index].x=this.imageList[this.current].tags[index].left/prod.clientWidth;
       this.imageList[this.current].tags[index].y=this.imageList[this.current].tags[index].top/prod.clientHeight;
    },
    onContextmenu(event,index){
      let id=index;
      this.$contextmenu({
        items: [
          {
            label: "タグ編集",
            onClick: () => {
              this.currentTag=id;
              this.dialogVisible=true;
              this.sanchi=this.imageList[this.current].tags[id].sanchi;
              this.price=this.imageList[this.current].tags[id].price;
              this.prodname=this.imageList[this.current].tags[id].prodname;
              this.ty=this.imageList[this.current].tags[id].ty
            }
          },
          {
            label: "タグ削除",
            onClick: () => {
              var arr=[]
              for(var i=0;i<this.imageList[this.current].tags.length;i++){
                if(i!=index){
                  if(i>index){
                    this.imageList[this.current].tags[i].index=this.imageList[this.current].tags[i].index-1;
                    arr.push(this.imageList[this.current].tags[i])
                  }else{
                    arr.push(this.imageList[this.current].tags[i])
                  }
                }
              }
              this.imageList[this.current].tags=arr;
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
      this.imageList[this.current].tags[this.currentTag].sanchi=this.sanchi;
      this.imageList[this.current].tags[this.currentTag].price=this.price;
      this.imageList[this.current].tags[this.currentTag].prodname=this.prodname;
      this.imageList[this.current].tags[this.currentTag].ty=this.ty;
      this.dialogVisible=false;
    }
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
</style>
