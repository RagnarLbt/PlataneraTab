const consultas =new Vue({
  el:'#gastos',
  data:{
    totalDineros:0,
    totalfech:0,
    prom:0,
    listaProductorCon:'',
    nombreGrafica:'',
  //PDF
    idPDF:'',
  //Consulta embarque
    id:0,
    id2:0,
    fecha1:'',
    fecha2:'',
    bolsasT:0,
    listaId:[],
    lista:[],
    listaRango:[],
    datosGastos: [],
  //Consulta Productor
    listaP:[],
    fecha1p:'',
    fecha2p:'',
    idE:0,
    idP:0,
    html2:'',
  //Consulta General
    fecha1g:'',
    fecha2g:'',
    lista1:[],
    lista2:[],
  //Consulta Grafica
    listaY:[],
    listaX:[],
    datosY:[],
    datosX:[],
    a1:[],
    a2:[],
  //consulta trabajadores
    listaTrabP:[],
    fech1:'',
    fech2:'',
    listaPB:[],
    listaPBFecha:[],
    idPel:[],
  //Bolseros
    listaB:[],
    idBol:0,
    listaBPagoEmb:[],
    listaBPagoFech:[],
  //Consulta grafica productor
    listaYProd:[],
    listaXProd:[],
    b1:[],
    b2:[],
  //Datos consulta 2 productor    
    listaP2:[],
    idProd:0,
    fecha1p2:'',
    fecha2p2:'',
    listaYProd2:[],
    listaXProd2:[],
    p1:[],
    p2:[],
  //Datos consulta 3 productor
    listaP3:[],
    idProd2:0,
    listaYProd3:[],
    listaYRend:[],
    listaXProd3:[],
    p3:[],
    max:0,
    pr3:[],
    p4:[],
  //Datos consulta 4 productor
    listaP4:[],
    listaP4Fecha:[],
    listaProductor:[],
    idPro:[],
    idEmb:0,
    idEmb2:0,
    listaYProd4:[],
    listaXProd4:[],
    listaYProd4F:[],
    listaXProd4F:[],
    p5:[],
    p6:[],
    p5F:[],
    p6F:[],
    listaFrutaP:[],
    idProductor:0,
    idEmbarque :0,
  //Consulta grafica embarque
    listaYEmb1:[],
    listaXEmb1:[],
    c1x:[],
    c1y:[],
    listaYEmb2:[],
    c2y:[],

  //Aguinaldo
    listAguiEmb:[],
    aY:[],
    aX:[],
    aguinaldoY:[],
    aguinaldoX :[],

    listAguiFech:[],
    afY:[],
    afX:[],
    aguinaldoYfech:[],
    aguinaldoXfech:[],
  //Pago a peladores
    listPelFech:[],
    listPelEmb:[],

    ppY:[],
    ppX:[],
    listaPagoPelY:[],
    listaPagoPelX:[],

    ppfY:[],
    ppfX:[],
    listaPagoPelFechaY:[],
    listaPagoPelFechaX:[],
    totalpago:0,

  //Abonos de productores
    listAboEmb:[],
    listAboFech:[],
  //Rendimiento de embarque 
    listaRE:[],
    idPel:0,
  //Reportes
    id_reporte:0,
    listaDatReporte: [],
  //Grafica Bolsas peladores
    t1Y:[],
    t1X:[],
    listat1Y:[],
    listat1X:[],
    t2Y:[],
    t2X:[],
    listat2Y:[],
    listat2X:[],

  //Pago Bolseros
    pbY:[],
    pbX:[],
    listarPagoBolseroY:[],
    listarPagoBolseroX:[],

    pbfY:[],
    pbfX:[],
    listarPagoBolseroFechaY:[],
    listarPagoBolseroFechaX:[],

},
methods:{
  //Botones
    btnBuscarId(id, id2){
      if(id!=0){
           this.listarEmbId(id, id2);
      }else{
        Swal.fire({
          title: 'Error inesperado',
          text: 'Ingrese un No. de embarque',
          icon: 'error',
          backdrop: false
        }); 
      }
    },
    btnConsultaT1(idPel,idEmb, idEmb2){
      if(idEmb!=0 && idPel!=0){
        this.listarPeladoresBolsas(idPel, idEmb, idEmb2);
        this.listarDatosT1Y(idPel,idEmb, idEmb2);
        this.listarDatosT1X(idPel,idEmb, idEmb2);
        
      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó por lo menos un embarque o productor',
          text: 'Seleccione un rango de embarques o embarque',
          backdrop: false
        }); 
      }
    },
    listarPeladoresBolsas(idPel,idEmb, idEmb2){
      this.totalfech=0;
      this.totalpago=0;
      axios.post(url_consultas,{option:27,idPel:idPel,idEmb:idEmb, idEmb2:idEmb2 }). then(response =>{
        this.listaPB = response.data;
        
        for(dat of response.data){
          this.totalfech=(parseInt(this.totalfech)+parseInt(dat.bolsas));
          this.totalpago=(parseInt(this.totalpago)+parseInt(dat.pago_pe))
        }
      });
    },

    btnConsultaT2(idPel,fech1, fech2){
      if(fech1!='' && idPel!=0){
        this.listarPeladoresBolsasFecha(idPel,fech1, fech2);
        this.listarDatosT2Y(idPel,fech1, fech2);
        this.listarDatosT2X(idPel,fech1, fech2);
      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó por lo menos una fecha o productor',
          text: 'Seleccione un rango de fechas o fecha',
          backdrop: false
        }); 
      }
    },
    listarPeladoresBolsasFecha(idPel,fech1, fech2){
      axios.post(url_consultas,{option:28,idPel:idPel,fech1:fech1, fech2:fech2 }). then(response =>{
        this.listaPBFecha = response.data;
        
      });
    },
  //Bolseros pagos
    btnConsultaTBol(idBol,idEmb, idEmb2){
      if(idEmb!=0 && idBol!=0){
        this. listaBolEmbarque(idBol,idEmb, idEmb2);
        this.listarPagoBolY(idBol,idEmb, idEmb2);
        this.listarPagoBolX(idBol,idEmb, idEmb2);


      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó por lo menos un embarque o bolsero',
          text: 'Seleccione un rango de embarques o embarque',
          backdrop: false
        }); 
      }
    },
    btnConsultaTBolFech(idBol,fech1, fech2){
      if(fech1!='' && idBol!=0){
        this.listaBolFecha(idBol,fech1, fech2);
        this.listarPagoBolFechaY(idBol,fech1, fech2);
        this.listarPagoBolFechaX(idBol,fech1, fech2);
      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó por lo menos una fecha o bolsero',
          text: 'Seleccione un rango de fechas o fecha',
          backdrop: false
        }); 
      }
    },
    //lista bolseros select
    listarBolserosPagos(){
      axios.post(url_trabajador,{option:5}). then(response =>{
          this.listaB = response.data;
          
      });
    },
    listaBolEmbarque(idBol,idEmb, idEmb2){
      axios.post(url_consultas,{option:29,  idBol:idBol,idEmb:idEmb, idEmb2:idEmb2}). then(response =>{
        this.listaBPagoEmb = response.data;
            
        });
    },
    listaBolFecha(idBol,fech1, fech2){
      axios.post(url_consultas,{option:30, idBol:idBol,fech1:fech1, fech2:fech2}). then(response =>{
        this.listaBPagoFech = response.data;
            
        });
    },

    //Aguinaldos
    btnAguinaldoFecha(fech1, fech2){
      this.listaAguiFecha(fech1, fech2);
      this.listarDatosAguiFechY(fech1, fech2);
      this.listarDatosAguiFechX(fech1, fech2);


    },

    listaAguiFecha(fech1, fech2){
      axios.post(url_consultas,{option:31, fech1:fech1, fech2:fech2}). then(response =>{
        this.listAguiFech = response.data;
            
        });
    },
    btnAguinaldoEmb(idEmb, idEmb2){
        this.listaAguiEmb(idEmb, idEmb2);
        this.listarDatosAguinaldoY(idEmb, idEmb2);
        this.listarDatosAguinaldoX(idEmb, idEmb2);

    },
    listaAguiEmb(idEmb, idEmb2){
      axios.post(url_consultas,{option:32, idEmb:idEmb, idEmb2:idEmb2}). then(response =>{
        this.listAguiEmb = response.data;
            
        });
    },
    //---Abonos de productores---
    btnAbonoFecha(idPro,fech1, fech2){
      this.listaAbonoFecha(idPro,fech1, fech2);
    },

    listaAbonoFecha(idPro,fech1, fech2){
      axios.post(url_consultas,{option:34, idPro:idPro,fech1:fech1, fech2:fech2}). then(response =>{
        this.listAboFech = response.data;
            
        });
    },
    btnAbonoEmb(idPro,idEmb, idEmb2){
        this.listaAbonoEmb(idPro,idEmb, idEmb2);
    },
    listaAbonoEmb(idPro,idEmb, idEmb2){
      axios.post(url_consultas,{option:35,idPro:idPro, idEmb:idEmb, idEmb2:idEmb2}). then(response =>{
        this.listAboEmb = response.data;
            
        });
    },
    //Pago peladores
    btnPagoFecha(idPel,fech1, fech2){
      this.listaPagoFecha(idPel,fech1, fech2);
      
      this.listarPagoPelFechaY(idPel,fech1, fech2);
      this.listarPagoPelFechaX(idPel,fech1, fech2);

    },

    listaPagoFecha(idPel,fech1, fech2){
      axios.post(url_consultas,{option:37, idPel:idPel,fech1:fech1, fech2:fech2}). then(response =>{
        this.listPelFech = response.data;
            
        });
    },
    btnPagoEmb(idPel,idEmb, idEmb2){
      
        this.listaPagoEmb(idPel,idEmb, idEmb2);
        this.listarPagoPelY(idPel,idEmb, idEmb2);
      this.listarPagoPelX(idPel,idEmb, idEmb2);
    },
    listaPagoEmb(idPel,idEmb, idEmb2){
      axios.post(url_consultas,{option:36,idPel:idPel, idEmb:idEmb, idEmb2:idEmb2}). then(response =>{
        this.listPelEmb = response.data;
            
        });
    },
    btnBuscarR(fecha1, fecha2){
      if(fecha1!='' && fecha2!=''){
        this.listarEmbRango(fecha1, fecha2);
        //Grafica bolsas, productor
        this.listarDatosYEmb(fecha1, fecha2);
        this.listarDatosXEmb(fecha1, fecha2);
        //Grafica gastos productor
        this.listarDatosYEmb2(fecha1, fecha2);

      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó fecha',
          text: 'Seleccione un rango de fechas',
          backdrop: false
        }); 
      }
    },
    btnConsultaP(fecha1p, fecha2p){
      if(fecha1p!='' && fecha2p!=''){
        this.listarProd(fecha1p, fecha2p);
        this.listarDatosYProd(fecha1p, fecha2p);
        this.listarDatosXProd(fecha1p, fecha2p);
      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó fecha',
          text: 'Seleccione un rango de fechas',
          backdrop: false
        }); 
      }
    },
    btnConsultaP2(idProd, fecha1p2, fecha2p2){
      if(idProd!=0 && fecha1p2!='' && fecha2p2!=''){
          this.listarProd2(idProd, fecha1p2, fecha2p2);
          this.listarDatosYProd2(idProd, fecha1p2, fecha2p2);
          this.listarDatosXProd2(idProd, fecha1p2, fecha2p2);
      }else{
        Swal.fire({
          icon:'error',
          title: 'No se seleccionó fecha o id de productor',
          text: 'Seleccione un rango de fechas o un id',
          backdrop: false
        });
      }
    },
    btnConsultaP3(idProd2){
      if(idProd2!=0 ){
        this.listarProd3(idProd2);
        this.listaProductoresC(idProd2);
        this.listarDatosYProd3(idProd2);
        this.listarDatosXProd3(idProd2);
        //this.listarDatosYRend(idProd2);
      }else{
        Swal.fire({
          icon: 'error',
          title: 'No se seleccionó fecha o id de productor',
          text: 'Seleccione un rango de fechas o un id',
          backdrop: false
        });
      }
    },
    btnConsultaP4(idPro, idEmb, idEmb2){
      if(idEmb!=0 ){
        this.listarProd4(idPro,idEmb, idEmb2);
        this.listarDatosYProd4(idPro,idEmb, idEmb2);
        this.listarDatosXProd4(idPro,idEmb, idEmb2);
      }else{
        Swal.fire({
          icon:'error',
          title: 'No se seleccionó fecha o id de productor',
          text: 'Seleccione un rango de fechas o un id',
          backdrop: false
        });
      }
    },
    btnConsultaP4Fecha(idPro, fech1, fech2){
      if(fech1!=''){
        this.listarProd4Fecha(idPro, fech1, fech2);
        this.listarDatosYProd4Fecha(idPro,fech1, fech2);
        this.listarDatosXProd4Fecha(idPro,fech1, fech2);
      }else{
        Swal.fire({
          icon:'error',
          title: 'No se seleccionó fecha o id de productor',
          text: 'Seleccione un rango de fechas o un id',
          backdrop: false
        });
      }
    },
    listarProd4Fecha(idPro, fech1, fech2){
     this.totalfech=0;
      axios.post(url_consultas,{option:33,idPro:idPro , fech1:fech1, fech2:fech2}).then(response=>{
       
        this.listaP4Fecha=response.data;  
        
        for(dat of response.data){
          this.totalfech=(parseFloat(this.totalfech)+parseFloat(dat.kg)).toFixed(2);
        }
      });
    },
    btnConsultaG(fecha1g, fecha2g){
        if(fecha1g!='' && fecha2g!=''){
          this.listarGeneral(fecha1g, fecha2g);
          this.total(fecha1g, fecha2g);
          this.listarDatosY(fecha1g, fecha2g);
          this.listarDatosX(fecha1g, fecha2g);
        }else{
          Swal.fire({
            icon:'error',
            title: 'No se seleccionó fecha',
            text: 'Seleccione un rango de fechas',
            backdrop: false
          });
        }
    },
    btnPDF1(id, num1, num2){
      this.generarPDF(id, 'Gastos de Embarque(s) '+num1+'  '+num2+'');
    },
    btnPDF2(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Gastos de fruta entre las fechas: '+fecha1+' a '+fecha2+'');
    },
    btnPDF3(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Historial de productores entre las fechas '+fecha1+' a '+fecha2+'');
    },
    btnPDF4(id, fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Historial del productor '+id+' entre las fechas: '+fecha1+' a '+fecha2+'');
    },
    btnPDF5(idProd, tablaId){
      this.generarPDF(tablaId,  'Historial del productor '+idProd+'');
    },
    btnPDF6(emb1, emb2, tablaId){
      this.generarPDF(tablaId,  'Rendimiento de  productor(es)  el/los embarque(s): '+emb1+'/'+emb2+'');
    },
    btnPDF7(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Todos los gastos del embarque de: '+fecha1+ ' a '+fecha2+'' );
    },
     //Rendimiento de prod por fecha
     btnPDF8(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Rendimiento de  productor(es)  la/las fecha(s): '+fecha1+ ' a '+fecha2+'' );
    },
    //Abono de productores 
    btnPDF9(id, num1, num2){
      this.generarPDF(id, 'Abono de productor(s) en el/los embarque(s): '+num1+'  '+num2+'');
    },

    btnPDF10(id, num1, num2){
      this.generarPDF(id, 'Abono de productor(s) en la/las fecha(s): '+num1+'  '+num2+'');
    },
    //Bolsas peladores
    btnPDF11(emb1, emb2, tablaId){
      this.generarPDF(tablaId,  'Bolsas pelador(es) por embarque: '+emb1+'/'+emb2+'');
    },
    btnPDF12(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Bolsas pelador(es) por fecha: '+fecha1+ ' a '+fecha2+'' );
    },
    //Aguinaldo por fecha
    btnPDF13(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Aguinaldo por fecha: '+fecha1+ ' a '+fecha2+'' );
    },
    //Aguinaldo por embarque
    btnPDF14(emb1, emb2, tablaId){
      this.generarPDF(tablaId, 'Aguinaldo por embarque: '+emb1+'/'+emb2+'');
    },
    //Pago bolseros
    btnPDF15(emb1, emb2, tablaId){
      this.generarPDF(tablaId, 'Pago bolsero(s) por embarque: '+emb1+'/'+emb2+'');
    },
    btnPDF16(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Pago bolsero(s) por fecha: '+fecha1+ ' a '+fecha2+'' );
    },
    //Pago peladores
    btnPDF17(emb1, emb2, tablaId){
      this.generarPDF(tablaId, 'Pago pelador(es) por embarque: '+emb1+'/'+emb2+'');
    },
    btnPDF18(fecha1, fecha2, tablaId){
      this.generarPDF(tablaId, 'Pago pelador(es) por fecha: '+fecha1+ ' a '+fecha2+'' );
    },
/**DESCARGAR GRÁFICAS COMO IMÁGENES */

download1( fecha1, fecha2){
this.descargarGrafica('#graficaE', 'Gastos de fruta entre las fechas: '+fecha1+' a '+fecha2+'' );
},
download2( fecha1, fecha2){
  this.descargarGrafica('#graficaP',  'Historial de productores entre las fechas '+fecha1+' a '+fecha2+'' );
},
download3(id, fecha1, fecha2){
  this.descargarGrafica('#graficaP2', 'Historial del productor '+id+' entre las fechas: '+fecha1+' a '+fecha2+'');
},
download4(idProd){
  this.descargarGrafica('#graficaP3', 'Historial del productor '+idProd+'');
},
download5(emb1, emb2){
  this.descargarGrafica('#graficaP4', 'Rendimiento de  productor(es)  el/los embarque(s): '+emb1+'/'+emb2+'');
},
download5f(fecha1, fecha2){
  this.descargarGrafica('#graficaP4',  'Rendimiento de  productor(es)  la/las fecha(s): '+fecha1+ ' a '+fecha2+'');
},
download6(fecha1, fecha2){
  this.descargarGrafica('#graficaG', 'Todos los gastos del embarque de: '+fecha1+ ' a '+fecha2+'');
},
download7(emb1, emb2){
  this.descargarGrafica('#graficaT1Canvas', 'Bolsas pelador(es) por embarque: '+emb1+'/'+emb2+'');
},
download8(fecha1, fecha2){
  this.descargarGrafica('#graficaT1Canvas', 'Bolsas pelador(es) por fecha: '+fecha1+ ' a '+fecha2+'' );
},

download9(fecha1, fecha2){
  this.descargarGrafica('#graficaAguinaldofecha', 'Aguinaldo por fecha: '+fecha1+ ' a '+fecha2+'');
},
download10(emb1, emb2){
  this.descargarGrafica('#graficaAguinaldoEmb',  'Aguinaldo por embarque: '+emb1+'/'+emb2+'');
},

download11(emb1, emb2){
  this.descargarGrafica( '#graficaPagoBol', 'Pago bolsero(s) por embarque: '+emb1+'/'+emb2+'');
},
download12(fecha1, fecha2){
  this.descargarGrafica('#graficaPagoBol', 'Pago bolsero(s) por fecha: '+fecha1+ ' a '+fecha2+'' );
},

download13(emb1, emb2){
  this.descargarGrafica('#graficaPagoPelador', 'Pago pelador(es) por embarque: '+emb1+'/'+emb2+'' );
},
download14(fecha1, fecha2){
  this.descargarGrafica('#graficaPagoPelador', 'Pago pelador(es) por fecha: '+fecha1+ ' a '+fecha2+'' );
},
descargarGrafica(id, nombre){
  $(id).get(0).toBlob(function(blob){
    saveAs(blob, nombre+".png")
  });
},
    generarPDFGrafica(idTabla, id2, texto){
      var objetivoImg = document.querySelector(id2);
      var doc = new jsPDF("p", "mm", "a4");

      //var width = doc.internal.pageSize.getWidth();
      //var height = doc.internal.pageSize.getHeight();

      var height = $(id2).height();
      var width = $(id2).width();

      html2canvas(objetivoImg).then(canvas => {

          doc.setFont("helvetica");
          doc.setFontType("bold");
          doc.setFontSize(20);
          doc.text(100, 10, 'AGROEXPORTACIONES CHONTALPA', null, null, 'center');

          doc.setFont("Arial");
          doc.setFontSize(11);
          doc.setFontType("normal");
          doc.text(100, 20, texto,null, 'center');

          doc.autoTable({
            startY: 25,
            html: idTabla,
            useCss: true, });
          
          doc.addPage('a4','l');

          doc.setFont("Arial");
          doc.setFontSize(11);
          doc.setFontType("normal");
          doc.text(100, 10, texto, null, null, 'center');

          doc.addImage(canvas, 'PNG', 0, 0, 150, 180);
          
          doc.save('Consulta '+texto+'.pdf');
          //doc.autoPrint();
      });
    },
    generarPDF(idPDF, titulo){
        var doc = new jsPDF("p", "mm", "a4");

        doc.setFont("helvetica");
        doc.setFontType("bold");
        doc.setFontSize(20);
        doc.text(100, 14, 'AGROEXPORTACIONES CHONTALPA', null, null, 'center');
        
        doc.setFont("Arial");
        doc.setFontSize(11);
        doc.setFontType("normal");
        doc.text(100, 20, titulo, null, null, 'center');
        doc.setFontSize(9);
        doc.autoTable({ 
          startY: 25,
          html: idPDF,
          useCss: true, })
        doc.save("Consulta "+titulo+".pdf")
    },
    btnGrafica(f1,f2){
      this.cargarGraficaL(this.a1, this.a2,  "Costo", 'graficaG', 'Gastos de los embarques entre las fechas: '+f1+' a '+f2+'');
    },
    btnGraficaP(f1, f2){
      this.cargarGraficaL(this.b1, this.b2, 'Total Kilos',  'graficaP','Gráfica de productores etre las fechas:'+f1+' a '+f2+'');
   },
   //Nuevas consultas
   btnGraficaP2(p, f1, f2){
     this.cargarGraficaProdRangFecha(this.p1, this.p2, 'Total Kilos', 'graficaP2', 'Gráfica del productor: '+p+' entre las fechas: '+f1+' a '+f2+'', this.max);
   },
   btnGraficaP3(){
     this.cargarGraficaProm(this.p3,this.p4, this.prom,'Fruta', 'graficaP3', 'Historial de  productor: '+this.nombreGrafica+'', this.max);
     this.cargarGraficaL(this.pr3, this.p4, 'Rendimiento', 'graficaRend','Rendimiento productor: '+this.nombreGrafica+' ');
   },
   btnGraficaP4(){
     this.cargarGraficaL(this.p5, this.p6, 'Peso fruta', 'graficaP4','');
   },
   btnGraficaP4fecha(){
     this.cargarGraficaL(this.p5F, this.p6F, 'Peso fruta', 'graficaP4','url5');
   },
//Grafica bolsas peladores
btnGraficaT1(id1, id2){
  if(id2==0){
   this.cargarGraficaL(this.t1Y, this.t1X, 'Bolsas', 'graficaT1Canvas','Bolsas de peladores en el embarque: '+id1+'');
  }
  else{
   this.cargarGraficaL(this.t1Y, this.t1X, 'Bolsas', 'graficaT1Canvas','Bolsas de peladores en los embarques: '+id1+''+id2+'');
  }

},

btnGraficaT1fecha(f1, f2){
 if(f2==''){
   this.cargarGraficaL(this.t2Y, this.t2X, 'Bolsas', 'graficaT1Canvas','Bolsas de peladores en la fecha '+f1+' ');
 }else{
   this.cargarGraficaL(this.t2Y, this.t2X, 'Bolsas', 'graficaT1Canvas','Bolsas de peladores entre las fechas: '+f1+' a  '+f2+'');
 }
},
//Grafica de aguinaldo
btnGraficaAguinaldo(id, id2){
 if(id2==0){
   this.cargarGraficaL(this.aY, this.aX, 'Aguinaldo', 'graficaAguinaldoEmb','Aguinaldo en el embarque: '+id+'');
 }else{
   this.cargarGraficaL(this.aY, this.aX, 'Aguinaldo', 'graficaAguinaldoEmb','Aguinaldo entre los embarques: '+id+' a '+id2+'');
 }
},

btnGraficaAguinaldofecha(f1, f2){
 if(f2==''){
   this.cargarGraficaL(this.afY, this.afX, 'Aguinaldo', 'graficaAguinaldofecha','Aguinaldo en la fecha: '+f1+'');
 }else{
   this.cargarGraficaL(this.afY, this.afX, 'Aguinaldo', 'graficaAguinaldofecha','Aguinaldo entre las fechas: '+f1+' a '+f2+'');
 }
},
//Grafica pago Bolseros
btnGraficaPagoBol(id, id2){
 if(id2==0){
   this.cargarGraficaL(this.pbY, this.pbX, 'Pago', 'graficaPagoBol','Pago a bolseros en el embarque: '+id+'');
 }else{
   this.cargarGraficaL(this.pbY, this.pbX, 'Pago', 'graficaPagoBol','Pago a bolseros entre los embarques: '+id+' a '+id2+'');
 }
},

btnGraficaPagoBolFecha(f1, f2){
if(f2==''){
 this.cargarGraficaL(this.pbfY, this.pbfX, 'Pago', 'graficaPagoBol','Pago a bolseros en la fecha: '+f1+'');
}else{
 this.cargarGraficaL(this.pbfY, this.pbfX, 'Pago', 'graficaPagoBol','Pago a bolseros entre las fechas:'+f1+' a '+f2+'');
}
},
//Grafica Pago Peladores
btnPagoPel(id, id2){
  if(id2==0){
    this.cargarGraficaL(this.ppY, this.ppX, 'Pago', 'graficaPagoPelador','Pago de peladores en el embarque: '+id+'');
  }else{
    this.cargarGraficaL(this.ppY, this.ppX, 'Pago', 'graficaPagoPelador','Pago de peladorador entre los embarques: '+id+' a '+id2+'');
  }
  
},
btnPagoPelfecha(f1, f2){
  if(f2==''){
    this.cargarGraficaL(this.ppfY, this.ppfX, 'Pago', 'graficaPagoPelador','Pago a peladores en la fecha: '+f1+'');
  }else{
    this.cargarGraficaL(this.ppfY, this.ppfX, 'Pago', 'graficaPagoPelador','Pago a peladores entre las fechas: '+f1+' a '+f2+'');
  }
},
    //==============
btnGraficaE(f1, f2){
     // this.cargarGraficaL(this.c2y, this.c1x, 'texto', 'graficaE');
      this.cargarGrafica2(this.c1y,  this.c2y, this.c1x, "Bolsas", "Gastos", 'graficaE','Gastos entre las fechas: '+f1+ ' a '+f2+'' );
},


  //Grafica con promedio
    cargarGraficaProm(datosY, datosX,promedio, texto, id, titulo, max){
      var ctx = document.getElementById(id).getContext('2d');
      if (window.graficaD) {
        window.graficaD.clear();
        window.graficaD.destroy();
      }
      
      window.graficaD = new Chart(ctx, {
          // The type of chart we want to create
          type: 'line',

          // The data for our dataset
          data: {
            labels: datosX,
            datasets: [{
              label: texto,
              lineTension:0,
              borderColor: 'rgb(51, 184, 255)',
              data:datosY
            },
            {
            label: 'Promedio: '+promedio+'',//Este es el nombre en la legenda
            fill: false, //Esto hace que no se rellene el area debajo de la línea
            radius: 0,//Esto hace que no se ven puntos para cada dato
            borderColor: 'rgb(255, 0, 0)',
            pointHitRadius: 0,//Esto evita que el tooltip aparezca cuando se pase el cursor encima de la línea
            data: datosX.map( label=>(promedio))//Este map crea un array del tamaño de usuarios con el valor que especifiques para la variable media
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                suggestedMin: 0,
                suggestedMax: max,
                stepSize: 100
              }
            }]
          },
          title: {
            display: true,
            text: titulo
          }
        },
        

      });
    },
    cargarGraficaProdRangFecha(datosY, datosX, texto, id, titulo, max){
      var ctx = document.getElementById(id).getContext('2d');
      
      if (window.graficaD) {
        window.graficaD.clear();
        window.graficaD.destroy();
      }
      
      window.graficaD = new Chart(ctx, {
        // The type of chart we want to create
        type: 'line',
        // The data for our dataset
        data: {
          labels: datosX,
          datasets: [{
            label: texto,
            lineTension:0,
            borderColor: 'rgb(51, 184, 255)',
            data:datosY
          }]
        },
        options: {
          scales: {
            yAxes: [{
              ticks: {
                suggestedMin: 0,
                suggestedMax: max,
                stepSize: 100
              }
            }]
          },
          title: {
            display: true,
            text: titulo
          }
        },
      });
    },
    cargarGraficaL(datosY, datosX, texto , id, titulo){
      var ctx = document.getElementById(id).getContext('2d');
      if(window.grafica){
        window.grafica.clear();
        window.grafica.destroy();
      }
      
      window.grafica = new Chart(ctx, {
          type: 'line',
          data: {
              labels: datosX,
              datasets: [{
                  label: texto,
                  lineTension:0,
                  borderColor: 'rgb(51, 184, 255)',
                  data: datosY,
                  pointStyle: 'circle',
                  pointRadius: 8,
                  pointBackgroundColor: 'rgb(0,120,215)'
              }]
          },options:{
            title:{
              display:true,
              text:titulo
            }
          }

      });  
      //var base64=grafica.toBase64Image();
      //document.getElementById(img).src=base64;
    },
    cargarGraficaL2(datosY, datosX, texto, id){
      var ctx = document.getElementById(id).getContext('2d');
      if (window.graficaD) {
        window.graficaD.clear();
        window.graficaD.destroy();
      }
      
      window.graficaD = new Chart(ctx, {
          // The type of chart we want to create
          type: 'line',

          // The data for our dataset
          data: {
              labels: datosX,
              lineTension:0,
              datasets: [{
                  label: texto,
                  borderColor: 'rgb(51, 184, 255)',
                  data: datosY
              }]
          },

      });
    },
    cargarGrafica2(dato1Y, dato2Y, datoX, texto1, texto2, id, titulo ){

      var ctx = document.getElementById(id).getContext('2d');
      if (window.grafica) {
        window.grafica.clear();
        window.grafica.destroy();
      }
      
      var dataFirst = {
        label: texto1,
        borderColor: 'rgb(51, 184, 255 )',
        data: dato1Y,
        lineTension: 0.3,
        lineTension:0,
      };
      
      var dataSecond = {
        label: texto2 ,
        borderColor: 'rgb(46, 165, 86 )',
        data: dato2Y,
        lineTension:0
      };
      
      var speedData = {
        labels: datoX,
        lineTension:0,
        datasets: [dataFirst, dataSecond]
      };
      
      window.grafica = new Chart(ctx, {
        type: 'line',
        data: speedData,
        title: {
          display: true,
          text: titulo
        }
      });
    },
  //Procedimientos
  //Consulta embarque
    listarDatosR:function (){
      axios.post(url_consultas,{option:23}). then(response =>{
        this.listaRE = response.data;
      });
    },
    listarEmbId(id, id2){
      axios.post(url_consultas,{option:2, id:id, id2:id2}).then(response =>{
        this.listaId = response.data;        
      });
      axios.post(url_consultas,{option:1, id:id,  id2:id2}).then(response =>{
        this.datosGastos = response.data;
      });
    },
    listarEmbRango: function (fecha1, fecha2){
      axios.post(url_consultas,{option:3, fecha1:fecha1, fecha2:fecha2}). then(response =>{
        this.listaRango = response.data;
      });
    },
  //Obtener datos grafica embarque
    listarDatosYEmb:function(fecha1, fecha2){
      this.c1y=[];
      axios.post(url_consultas,{option:11, fecha1:fecha1, fecha2:fecha2}).then(response=>{
        this.listaYEmb1=response.data;

        for(cant of this.listaYEmb1){
          this.c1y.push(cant.cantidad);
        };
        
      });
    },
    listarDatosXEmb:function(fecha1, fecha2){
      this.c1x=[];
      axios.post(url_consultas,{option:12, fecha1:fecha1, fecha2:fecha2}).then(response=>{
        this.listaXEmb1=response.data;
        

        for(cant of this.listaXEmb1){
          this.c1x.push(cant.id);
        };
        
      });
    },
    listarDatosYEmb2:function(fecha1, fecha2){
      this.c2y=[];
      axios.post(url_consultas,{option:13, fecha1:fecha1, fecha2:fecha2}).then(response=>{
        this.listaYEmb2=response.data;
        
        for(cant of this.listaYEmb2){
          this.c2y.push(cant.gastos);
        };
        
      });
    },
  //Consulta productor
    listarProd(fecha1p, fecha2p){
      this.totalDineros=0;
      this.totalfech=0;
      axios.post(url_consultas,{option:4, fecha1p:fecha1p, fecha2p:fecha2p}).then(response=>{
        this.listaP=response.data;
        for(dat of response.data){
          this.totalfech=(parseFloat(this.totalfech)+parseFloat(dat.kg)).toFixed(2);
          this.totalDineros=(parseFloat(this.totalDineros)+parseFloat(dat.total)).toFixed(2);
        }
      });
    },
    listarDetallesP(idE, idP){
      axios.post(url_consultas,{option:24, idE:idE, idP:idP}).then(response=>{
        this.html2=response.data;
        
      }); 
    },
    listarProd2(idProd, fecha1p2, fecha2p2){
      axios.post(url_consultas,{option:14, idProd:idProd, fecha1p2:fecha1p2, fecha2p2:fecha2p2}).then(response=>{
        this.listaP2=response.data;
      });
    },
    //Grafica datos Y
    listarDatosYProd2(idProd, fecha1p2, fecha2p2){
      this.p1=[];
      this.max=[];

      axios.post(url_consultas,{option:17,idProd:idProd, fecha1p2:fecha1p2, fecha2p2:fecha2p2}).then(response=>{
        this.listaYProd2=response.data;
        for(cant of this.listaYProd2){
          this.p1.push(cant.peso);
        };
      });

      /* Valor Maxiomo del eje Y*/
      axios.post(url_consultas,{option:49, fecha_uno: fecha1p2, fecha_dos: fecha2p2}).then(response=>{
        this.max=response.data;

        for(dat of response.data){
          this.max=dat.m;
        }
      });

    },
    //Grafica datos x
    listarDatosXProd2:function(idProd, fecha1p2, fecha2p2){
      this.p2=[];
      axios.post(url_consultas,{option:18, idProd:idProd, fecha1p2:fecha1p2, fecha2p2:fecha2p2}).then(response=>{
        this.listaXProd2=response.data;

        for(cant of this.listaXProd2){
          this.p2.push(cant.fecha);
        }
      });
    },

  //======================
    listarProd3:function(idProd2){
      axios.post(url_consultas,{option:15, idProd2:idProd2}).then(response=>{
        this.listaP3=response.data;
      });
  
    },

  //Grafica datos y (peso)
    listarDatosYProd3(idProd2){
      this.p3=[];
      this.pr3=[];
      this.max=[];
      axios.post(url_consultas,{option:19, idProd2:idProd2}).then(response=>{
        this.listaYProd3=response.data;

        for(row of this.listaYProd3){
          this.p3.push(row.peso);
        }
      });
      
      /* Valor Maxiomo del eje Y*/
      axios.post(url_consultas,{option:48}).then(response=>{
        this.max=response.data;
        
        for(dat of response.data){
          this.max=dat.m;
        }
      });
      
      /* Rendimiento de la fruta */
      axios.post(url_consultas,{option:26, idProd2:idProd2}).then(response=>{
        this.listaYRend=response.data;
        
        for(row of this.listaYRend){
          this.pr3.push(row.rend);
        };
      });
    
      /* Promedio de compra de la frura */
      axios.post(url_consultas,{option:46, idProd2:idProd2}).then(response=>{
        this.prom=response.data;
        for(dat of response.data){
          this.prom=dat.promedio;
        }
      });

   },
//nombre de productores para grafica
   listaProductoresC(id){
    
    axios.post(url_consultas,{option:47, id:id}). then(response =>{        
      this.listaProductorCon = response.data;
      this.nombreGrafica='';
      for(dat of response.data){
        this.nombreGrafica=dat.nombre;
      }
    });
  
   
  },
    /*Grafica datos y (rendimiento de productor)
    listarDatosYRend:function(idProd2){
     
      axios.post(url_consultas,{option:25, idProd2:idProd2}).then(response=>{
        this.listaYRend=response.data;
        

        for(row of this.listaYRend){
          this.pr3.push(row.rend);
        };
        

      });
    },
    */
  //Grafica datos x (id embarques)
    listarDatosXProd3:function(idProd2){
      this.p4=[];
      axios.post(url_consultas,{option:20, idProd2:idProd2}).then(response=>{
        this.listaXProd3=response.data;
        
        for(row of this.listaXProd3){
          this.p4.push(row.embarque);
        };
        

      });
    },
  //========================
    listarProd4:function(idPro,idEmb, idEmb2){
      this.totalfech=0;
      axios.post(url_consultas,{option:16,idPro:idPro , idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
       
        this.listaP4=response.data;
        
        for(dat of response.data){
          this.totalfech=(parseFloat(this.totalfech)+parseFloat(dat.kg)).toFixed(2);
        }
        
      });
    },
    listarProductores (){
      axios.post(url_productor,{option:5}). then(response =>{
        
          this.listaProductor = response.data;
         
      });
    },
//----------Grafica bolsas peladores 

listarDatosT1Y(idPel, idEmb, idEmb2){
  this.t1Y=[];
  axios.post(url_consultas,{option:38,op:1, idPel:idPel, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listat1Y=response.data;
    

    for(row of this.listat1Y){
      this.t1Y.push(row.e);
    };
    

  });
},

listarDatosT1X(idPel,idEmb, idEmb2){
  this.t1X=[];
  axios.post(url_consultas,{option:39,op:1, idPel:idPel,  idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listat1X=response.data;
    

    for(row of this.listat1X){
      this.t1X.push(row.e);
    };
   

  });
},
//-----------------
listarDatosT2Y(idPel, fech1, fech2){
  this.t2Y=[];
  axios.post(url_consultas,{option:38,op:2, idPel:idPel, fech1:fech1, fech2:fech2}).then(response=>{
    this.listat2Y=response.data;

    for(row of this.listat2Y){
      this.t2Y.push(row.e);
    };

  });
},

listarDatosT2X(idPel, fech1, fech2){
  this.t2X=[];
  axios.post(url_consultas,{option:39, op:2, idPel:idPel, fech1:fech1, fech2:fech2}).then(response=>{
    this.listat2X=response.data;
  

    for(row of this.listat2X){
      this.t2X.push(row.e);
    };
    

  });
},
//----------Grafica pago Bolseros

listarPagoBolY(idBol, idEmb, idEmb2){
  this.pbY=[];
  axios.post(url_consultas,{option:42,op:1, idBol:idBol, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listarPagoBolseroY=response.data;
    

    for(row of this.listarPagoBolseroY){
      this.pbY.push(row.e);
    };
   

  });
},

listarPagoBolX(idBol,idEmb, idEmb2){
  this.pbX=[];
  axios.post(url_consultas,{option:43,op:1, idBol:idBol,  idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listarPagoBolseroX=response.data;
    

    for(row of this.listarPagoBolseroX){
      this.pbX.push(row.e);
    };
   

  });
},
//-----------------
listarPagoBolFechaY(idBol, fech1, fech2){
  this.pbfY=[];
  axios.post(url_consultas,{option:42,op:2, idBol:idBol, fech1:fech1, fech2:fech2}).then(response=>{
    this.listarPagoBolseroFechaY=response.data;


    for(row of this.listarPagoBolseroFechaY){
      this.pbfY.push(row.e);
    };
    

  });
},

listarPagoBolFechaX(idBol, fech1, fech2){
  this.pbfX=[];
  axios.post(url_consultas,{option:43, op:2, idBol:idBol, fech1:fech1, fech2:fech2}).then(response=>{
    this.listarPagoBolseroFechaX=response.data;
  

    for(row of this.listarPagoBolseroFechaX){
      this.pbfX.push(row.e);
    };
    

  });
},

//----------Grafica pago Peladores

listarPagoPelY(idPel, idEmb, idEmb2){
  this.ppY=[];
  axios.post(url_consultas,{option:44,op:1, idPel:idPel, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listaPagoPelY=response.data;
    

    for(row of this.listaPagoPelY){
      this.ppY.push(row.e);
    };
    

  });
},

listarPagoPelX(idPel,idEmb, idEmb2){
  this.ppX=[];
  axios.post(url_consultas,{option:45,op:1, idPel:idPel,  idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
    this.listaPagoPelX=response.data;
    

    for(row of this.listaPagoPelX){
      this.ppX.push(row.e);
    };
   

  });
},
//-----------------
listarPagoPelFechaY(idPel, fech1, fech2){
  this.ppfY=[];
  axios.post(url_consultas,{option:44,op:2, idPel:idPel, fech1:fech1, fech2:fech2}).then(response=>{
    this.listaPagoPelFechaY=response.data;


    for(row of this.listaPagoPelFechaY){
      this.ppfY.push(row.e);
    };
    

  });
},

listarPagoPelFechaX(idPel, fech1, fech2){
  this.ppfX=[];
  
  axios.post(url_consultas,{option:45, op:2, idPel:idPel, fech1:fech1, fech2:fech2}).then(response=>{
    this.listaPagoPelFechaX=response.data;
  

    for(row of this.listaPagoPelFechaX){
      this.ppfX.push(row.e);
    };
    

  });
},
  //-------Aguinaldo de embarques
  listarDatosAguinaldoY( idEmb, idEmb2){
    this.aY=[];
    axios.post(url_consultas,{option:40,op:1, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
      this.aguinaldoY =response.data;
      
  
      for(row of this.aguinaldoY ){
        this.aY.push(row.e);
      };
     
  
    });
  },
  
  listarDatosAguinaldoX(idEmb, idEmb2){
    this.aX=[];
    axios.post(url_consultas,{option:41,op:1,  idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
      this.aguinaldoX =response.data;
      
  
      for(row of this.aguinaldoX ){
        this.aX.push(row.e);
      };
     
  
    });
  },
  //----------Por fecha-------
  listarDatosAguiFechY(fech1, fech2){
    this.afY=[];
    axios.post(url_consultas,{option:40,op:2,  fech1:fech1, fech2:fech2}).then(response=>{
      this.aguinaldoYfech=response.data;
  
  
      for(row of this.aguinaldoYfech){
        this.afY.push(row.e);
      };
      
  
    });
  },
  
  listarDatosAguiFechX( fech1, fech2){
    this.afX=[];
    axios.post(url_consultas,{option:41, op:2, fech1:fech1, fech2:fech2}).then(response=>{
      this.aguinaldoXfech=response.data;
      
  
      for(row of this.aguinaldoXfech){
        this.afX.push(row.e);
      };
      
  
    });
  },


  //Grafica datos y (peso)
    listarDatosYProd4(idPro, idEmb, idEmb2){
      this.p5=[];
      axios.post(url_consultas,{option:21, op:1, idPro:idPro, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
        this.listaYProd4=response.data;
        
  
        for(row of this.listaYProd4){
          this.p5.push(row.e);
        };
        
  
      });
    },
    //---------Rendimiento productores por fecha

    listarDatosYProd4Fecha(idPro, fech1, fech2){
      this.p5F=[];
      axios.post(url_consultas,{option:21,op:2, idPro:idPro, fech1:fech1, fech2:fech2}).then(response=>{
        this.listaYProd4F=response.data;
    
  
        for(row of this.listaYProd4F){
          this.p5F.push(row.e);
        };
        
  
      });
    },

    listarDatosXProd4Fecha(idPro, fech1, fech2){
      this.p6F=[];
      axios.post(url_consultas,{option:22, op:2, idPro:idPro, fech1:fech1, fech2:fech2}).then(response=>{
        this.listaXProd4F=response.data;
      
  
        for(row of this.listaXProd4F){
          this.p6F.push(row.e);
        };
        
  
      });
    },
    //Grafica datos x (id productores)
    listarDatosXProd4:function(idPro,idEmb, idEmb2){
      this.p6=[];
      axios.post(url_consultas,{option:22,op:1, idPro:idPro, idEmb:idEmb, idEmb2:idEmb2}).then(response=>{
        this.listaXProd4=response.data;
         
  
        for(row of this.listaXProd4){
          this.p6.push(row.e);
        };
       
  
      });
    },
  //=============================
    listarDatosYProd(fecha1p, fecha2p){
      this.b1=[];
      axios.post(url_consultas,{option:9, fecha1p:fecha1p, fecha2p:fecha2p}).then(response=>{
        this.listaYProd=response.data;
         
        for(cant of this.listaYProd){
          this.b1.push(cant.total);
        };
     

      });
    },
    listarDatosXProd:function(fecha1p, fecha2p){
      this.b2=[];
      axios.post(url_consultas,{option:10, fecha1p:fecha1p, fecha2p:fecha2p}).then(response=>{
        this.listaXProd=response.data;

        for(cant of this.listaXProd){
          this.b2.push(cant.id);
        };
        

      });
    },
  //Consulta general
    listarGeneral:function(fecha1g, fecha2g){
      axios.post(url_consultas,{option:5, fecha1g:fecha1g, fecha2g:fecha2g}).then(response=>{
        this.lista1=response.data;
      });
    },
    total:function(fecha1g, fecha2g){
      axios.post(url_consultas,{option:6, fecha1g:fecha1g, fecha2g:fecha2g}).then(response=>{
        this.lista2=response.data;
      });
    },
    listarDatosY:function(fecha1g, fecha2g){
      this.a1=[];
      axios.post(url_consultas,{option:7, fecha1g:fecha1g, fecha2g:fecha2g}).then(response=>{
        this.listaY=response.data;

        for(cant of this.listaY){
          this.a1.push(cant.cantidad);
        };

      });
    },
    listarDatosX:function(fecha1g, fecha2g){
      this.a2=[];
      axios.post(url_consultas,{option:8, fecha1g:fecha1g, fecha2g:fecha2g}).then(response=>{
        this.listaX=response.data;

        for(cant of this.listaX){
          this.a2.push(cant.fecha);
        };
      });
    },
  //Listar Reportes
    btnEmbarqueReporte(id){
      if(id>=1){
        axios.post(url_consultas,{option:25, id:id}).then(response=>{
          this.listaDatReporte=response.data;
        });
      }else{
        Swal.fire({
          title: 'Dato no exitente',
          text: 'Ingrese un No. de Embarque valido',
          icon: 'warning',
          backdrop: false
        });
      }
    },

    listarPeladores(){
      axios.post(url_trabajador,{option:4}). then(response =>{
        this.listaTrabP = response.data;
            
        });
    },
  //Fotos Fruta
  //foto fruta
    btnConsultaFoto(idEmbarque, idProductor){
      if(idEmbarque!=0 && idProductor!=0){
        this.consultarFoto(idEmbarque, idProductor);
      }else{
        Swal.fire({
          title: 'Datos incompletos',
          text: 'Ingrese los datos en los campos correctos',
          icon: 'warning',
          backdrop: false
        }); 
      }
    },
    consultarFoto(embActual, idProd){
      axios.post(url_embarque, {option:8, idProd:idProd, embActual:embActual}).then(response=>{
        this.listaFrutaP=response.data;
        
      }).catch(e => {
          // Mostramos los errores
          Swal.fire({
            icon: 'error',
            title: 'Error de Solicitud HTTP',
            text: 'Error '+e+', comunique a Soporte la existencia del error.',
            backdrop: false
          });
        });
    },
    async verFoto(foto){
      await Swal.fire({
        title: '',
        html: ''+
        '<div class="row col-sm-12 container">'+
        '<div class="col-sm-12">'+
        '<div class="form-group p-1 mt-3">'+
        '<img src="'+foto+'" width="100%" alt="foto">'+
        '</div>'+
        '</div></div>',
        width: 500,
        focusConfirm: false,
        showCancelButton: false,
        confirmButtonText: 'Aceptar',
        backdrop: false
      });
    }
  },
  created: function(){ 
        //this.listarDatosRE();
        this.listarProductores ();
        this.listarDatosR();
        this.listarPeladores();
        this.listarBolserosPagos();
    },
  computed:{

  }
});