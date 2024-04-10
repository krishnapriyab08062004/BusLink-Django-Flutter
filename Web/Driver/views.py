from django.shortcuts import render
from django.shortcuts import render,redirect
from Guest.models import *
from Admin.models import*
from BusLink.settings import *
from django.core.mail import send_mail
from django.conf import settings
from django.contrib import messages
from datetime import datetime
from django.http import HttpResponse
import json
import qrcode
from io import BytesIO
from django.core.files.base import ContentFile
from django.core.files.storage import default_storage
# Create your views here.
def driverhomepage(request):       
    driver=db.collection("tbl_driver").document(request.session["did"]).get().to_dict()
    return render(request,"Driver/Driverhomepage.html",{"driver":driver})

def driverchangepassword(request):
        user = db.collection("tbl_driver").document(request.session["did"]).get().to_dict()
        email = user['driver_mail']
        # print(email)
        em_link = firebase_admin.auth.generate_password_reset_link(email)
        send_mail(
            'Reset your password ', #subject
            "\rHello \r\nFollow this link to reset your Project password for your " + email + "\n" + em_link +".\n If you didn't ask to reset your password, you can ignore this email. \r\n Thanks. \r\n Your D MARKET team.",#body
            settings.EMAIL_HOST_USER,
            [email],
        )              
        return render(request, "Driver/DriverMyprofile.html") #use profile of student.html    

#DRIVER PROFILE
def driverprofile(request): 
    driver_id = request.session.get("did")
    if driver_id:
        driver_ref = db.collection("tbl_driver").document(driver_id).get().to_dict()
        return render(request,"Driver/DriverMyprofile.html",{"driver": driver_ref})
    else:
        return render(request,"Driver/Driverhomepage.html")       

def edit_driverprofile(request):
    addata=db.collection("tbl_driver").document(request.session["did"]).get().to_dict()
    if request.method == "POST":
        Images=request.FILES.get("txtimage3")
        if Images:
            path="User/Driver_photo/"+Images.name
            sd.child(path).put(Images)
            new_url=sd.child(path).get_url(None)
            db.collection("tbl_driver").document({"driver_img":new_url})
        db.collection("tbl_driver").document(request.session["did"]).update({"driver_name": request.POST.get('txtname3'),"dcon":request.POST.get('txtcon3')})
        return redirect("webdriver:driverprofile")
    else:
        return render(request,"Driver/Drivereditprofile.html",{"driver":addata}) 

def drivercomplaints(request):
    id=request.session["did"]

    compdata=db.collection("tbl_complaints").where("driver_id", "==", request.session["did"]).stream()
    complist=[]
    for i in compdata:
        comp=i.to_dict()
        complist.append({"comp_data":comp,"id":i.id})
        
    if request.method=="POST":
        data={"complaint_title":request.POST.get("txtctitle")
            ,"complaint_content":request.POST.get("txtccontent"),"driver_id":id,"stu_id":0}
        db.collection("tbl_complaints").add(data)
        return redirect("webdriver:drivercomplaints")
    else:
        return render(request,"Driver/Drivercomplaints.html",{"data":complist})


def driverfeedbacks(request):
    id=request.session["did"]

    compdata=db.collection("tbl_feedbacks").where("driver_id", "==", request.session["did"]).stream()
    complist=[]
    for i in compdata:
        comp=i.to_dict()
        complist.append({"comp_data":comp,"id":i.id})
        
    if request.method=="POST":
        data={"feedback_content":request.POST.get("txtfcontent"),
         "feedback_time":datetime.now(),
            "driver_id":id,"stu_id":0}
        db.collection("tbl_feedbacks").add(data)
        return redirect("webdriver:driverhomepage")
    else:
        return render(request,"Driver/Driverfeedback.html",{"data":complist})   
        
def busdetails(request):
    driver_id = request.session["did"]
    compdata = db.collection("tbl_assign").where("driver_id", "==", driver_id).stream()
    complist = []
    for doc in compdata:
        comp = doc.to_dict() 
        bdata_doc = db.collection("tbl_bus").document(comp["bus_id"]).get()
        bdata = bdata_doc.to_dict()
        complist.append({
                "comp_data": comp,
                "bdata": bdata,
                "id": doc.id
            })
     
    # print(complist)
    return render(request, "Driver/Busdetails.html", {"data": complist})

def generate_qrcode(request):
    assigndata = db.collection("tbl_assign").where("driver_id", "==", request.session['did']).stream()
    asdata=[]
    ids = ""
    for i in assigndata:
        d1=i.to_dict()
        ids = i.id
        asdata.append({"as_data":d1,"id":i.id})
    # print(ids)

    data = {'id': ids,'app':'BUSLINK'}
    data_json = json.dumps(data)
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_L,
        box_size=10,
        border=4,
    )
    qr.add_data(data_json)
    qr.make(fit=True)
    qr_img = qr.make_image(fill_color="black", back_color="white")
    buffer = BytesIO()
    qr_img.save(buffer)
    buffer.seek(0)
    return HttpResponse(buffer.getvalue(), content_type='image/png')


def studetails(request): 
    driver_id = request.session["did"]
    compdata = db.collection("tbl_assign").where("driver_id", "==", driver_id).stream()
    complist = []
    for doc in compdata:
        comp = doc.to_dict() 
        rdata_doc = db.collection("tbl_route").document(comp["route_id"]).get()
        rdata = rdata_doc.to_dict()
        sdata_doc = db.collection("tbl_stop").document(rdata["stop_id"]).get()
        sdata = sdata_doc.to_dict()
        stddata_doc = db.collection("tbl_stdstp").document(sdata["stop_id"]).get()
        stddata = stddata_doc.to_dict()  
        studata_doc = db.collection("tbl_student").document(stddata["stu_id"]).get()
        studata = studata_doc.to_dict()      

        complist.append({
            "comp_data": comp,
            "studata": studata,
            "id": doc.id
        })
        print(complist)
    return render(request, "Driver/Studetails.html", {"data": complist})



def Alerts(request):
    id=request.session["did"]

    compdata1 = db.collection("tbl_assign").where("driver_id", "==", id).stream()
    complist1 = []
    for doc in compdata1:
        comp = doc.to_dict() 
        bdata_doc = db.collection("tbl_route").document(comp["route_id"]).get()
        bdata = bdata_doc.to_dict()
        complist1.append({
                "comp_data": comp,
                "bdata": bdata,
                "id": doc.id
            })
       
    
     
    alert_datetime = datetime.now()
    compdata=db.collection("tbl_alerts").where("driver_id", "==", request.session["did"]).stream()
    complist=[]
    for i in compdata:
        comp=i.to_dict()
        complist.append({"comp_data2":comp,"id":i.id})
        
    if request.method=="POST":
        data={"alert_detail":request.POST.get("txtdetail")
            ,"alert_datetime":alert_datetime,"driver_id":id}
        db.collection("tbl_alerts").add(data)
        return redirect("webdriver:alerts")
    else:
        return render(request,"Driver/Alerts.html",{"data":complist,"alert_datetime":alert_datetime,"complist1":complist1})


def delete_alert(request,alid):
    db.collection("tbl_alerts").document(alid).delete()
    return redirect("webdriver:alerts")  

      
