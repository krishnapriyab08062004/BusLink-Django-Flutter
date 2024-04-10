from django.shortcuts import render,redirect
from Guest.models import *
from Admin.models import*
from BusLink.settings import *
from django.core.mail import send_mail
from django.conf import settings
from django.contrib import messages
# from django.shortcuts import render,redirect
# import firebase_admin
# from firebase_admin import storage,auth,firestore,credentials
# import pyrebase



# Create your views here.

def userreg(request):

        dis = db.collection("tbl_district").stream()
        dis_data = []
        for d in dis:
                data =d.to_dict()
                dis_data.append({"dis":data,"id":d.id})
        de= db.collection("tbl_department").stream()
        dep_data = []
        for dep1 in de :
                data =dep1.to_dict()
                dep_data.append({"de":data,"id":dep1.id})        
        if request.method=="POST":
                email = request.POST.get("txtmail")
                password = request.POST.get("txtpass")
                try:
                        student = firebase_admin.auth.create_user(email=email,password=password)
                except (firebase_admin._auth_utils.EmailAlreadyExistsError,ValueError) as error:
                        return render(request,"Guest/Studentregistration.html",{"msg":error})
                Images=request.FILES.get("fileimage")
                Imagesproof=request.FILES.get("fileproof")
                if Images:
                        path="User/User_photo/"+Images.name
                        sd.child(path).put(Images)
                        img_url=sd.child(path).get_url(None)
                if Imagesproof:
                        path="ID/Student_proof/"+Imagesproof.name
                        sd.child(path).put(Imagesproof)
                        img_url1=sd.child(path).get_url(None)        
                      
                db.collection("tbl_student").add({"stu_name":request.POST.get('txtname'),"stucon":request.POST.get('txtcon'),
                "stu_mail": request.POST.get('txtmail'),"stu_gender":request.POST.get('gender'),"stu_city":request.POST.get('txtadd'),"stu_pin":request.POST.get('txtpin'),
                "stu_house":request.POST.get('txthouse'),"stu_img":img_url,"stu_proof":img_url1,"stu_id":student.uid,"stu_batch":request.POST.get('txtbatch'),
                "stu_roll":request.POST.get('txtroll'),"stu_gname":request.POST.get('txtgname'),"stu_dob":request.POST.get('txtdob'),"stu_gcon":request.POST.get('txtgcon'),"stu_status":0,
                "dep_id":request.POST.get('sel_dep'),"place_id":request.POST.get('sel_place')
                })
                return render(request,"Guest/Studentregistration.html")
        else:
                return render(request,"Guest/Studentregistration.html",{"district":dis_data,"d1":dep_data})

def ajax_place(request):

    place=db.collection("tbl_place").where("district_id", "==", request.GET.get('did')).stream()
    pla_data =[]
    for p in place:
        pla_data.append({"place":p.to_dict(),"id":p.id})
    return render(request,"Guest/AjaxPlace.html",{"pdata":pla_data})  



def ajax_course(request):

    place=db.collection("tbl_course").where("dep_id", "==", request.GET.get('cid')).stream()
    pla_data =[]
    for p in place:
        pla_data.append({"place1":p.to_dict(),"id":p.id})
    return render(request,"Guest/AjaxCourse.html",{"pdata1":pla_data})  

def driverreg(request):
        if request.method=="POST":
                email = request.POST.get("txtmail")
                password = request.POST.get("txtpass")
                try:
                        driver = firebase_admin.auth.create_user(email=email,password=password)
                except (firebase_admin._auth_utils.EmailAlreadyExistsError,ValueError) as error:
                        return render(request,"Guest/Driverregistration.html",{"msg":error})
                Images=request.FILES.get("filedimage")
                if Images:
                        path="Driver/Driver_photo/"+Images.name
                        sd.child(path).put(Images)
                        img_url=sd.child(path).get_url(None)
                db.collection("tbl_driver").add({"driver_name":request.POST.get('txtdname'),"dcon":request.POST.get('txtdcon'),
                "driver_mail": request.POST.get('txtmail'),"driver_img":img_url,"driver_id":driver.uid,"driver_lno":request.POST.get('txtlno'),
                "driver_exp":request.POST.get('txtdexp'),"driver_status":0 })
          
                return render(request,"Guest/Driverregistration.html")
        else:
                return render(request,"Guest/Driverregistration.html")


def login(request):      
        adminid=""
        stuid=""
        driverid=""
        if request.method == "POST":
                email = request.POST.get("txtmail")
                password = request.POST.get("txtpass")
                try:
                        data = authe.sign_in_with_email_and_password(email, password)
                except:
                        return render(request, "Guest/Login.html", {"msg": "Email and password Error"})
                        
                ids = data["localId"]
                admin = db.collection("tbl_admin").where("admin_id", "==", ids).stream() 
                for a in admin:                                       
                        adminid = a.id 
                student=db.collection("tbl_student").where("stu_id", "==", ids).stream()  
                for u in student:
                        stuid=u.id 
                        sstatus=u.get("stu_status")
                driver = db.collection("tbl_driver").where("driver_id", "==", ids).stream() 
                for d in driver:                                       
                        driverid=d.id
                        drivername=d.get("driver_name")
                        dstatus=d.get("driver_status") 

                  

                if adminid:
                        request.session["aid"] = adminid
                        return redirect("webadmin:homepage")
                elif stuid and sstatus == 1:
                        request.session["sid"] =stuid
                        return redirect("webstudent:stuhomepage")
                elif driverid and dstatus == 1:  
                        request.session["did"] =driverid
                        request.session["dname"]=drivername
                        return redirect("webdriver:driverhomepage")      
                else:
                        return redirect("webguest:login", {"msg": "Error"})
                        
        else:

                return render(request,"Guest/Login.html")


     
     
        
 

        
    
                    


     
    


   