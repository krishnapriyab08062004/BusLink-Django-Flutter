from django.shortcuts import render,redirect
from Admin.models import *
from BusLink.settings import *
from django.core.mail import send_mail
from django.conf import settings
from django.contrib import messages
from datetime import datetime
# from django.shortcuts import render,redirect
# import firebase_admin
# from firebase_admin import *
# import pyrebase

# Create your views here.

#District
def district(request):
    dis = db.collection("tbl_district").stream()
    dis_data = []
    for d in dis:
        data =d.to_dict()
        dis_data.append({"dis":data,"id":d.id})
        # dis_data.append({"dis":d.to_dict(),"id":d.id})
  
    if request.method=="POST":
        # tbl_district.objects.create(district_name=request.POST.get('txtdis'))
        dist = request.POST.get('txtdis')
        dis_dict = {"district_name":dist}
        db.collection("tbl_district").add(dis_dict)
        # db.collection("tbl_district").add({"district_name":request.POST.get('txtdis')})
        return render(request,"Admin/District.html")
    else:
        return render(request,"Admin/District.html",{"district":dis_data})


def delete_dis(request,delid):
    # tbl_district.objects.get(id=delid).delete()
    db.collection("tbl_district").document(delid).delete()
    return redirect("webadmin:district")

def edit_dis(request,editid):
    dis = db.collection("tbl_district").document(editid).get().to_dict()
    if request.method == "POST":
        dist = request.POST.get('txtdis')
        dis_dict = {"district_name":dist}
        db.collection("tbl_district").document(editid).update(dis_dict)
        return redirect("webadmin:district")
    else:
        return render(request,"Admin/District.html",{"disdata":dis})

#Place
def place(request):
    dis = db.collection("tbl_district").stream()
    dis_data = []
    for d in dis:
        data =d.to_dict()
        dis_data.append({"dis":data,"id":d.id})

    place = db.collection("tbl_place").stream()
    place_data = []
    for p in place:
        place =p.to_dict()
        district=db.collection("tbl_district").document(place["district_id"]).get().to_dict()
        place_data.append({"place":place,"id":p.id,"dis_name":district})    

    if request.method=="POST":
        db.collection("tbl_place").add({"place_name":request.POST.get('txtplace'),"district_id":request.POST.get("seldistrict")})
        return render(request,"Admin/Place.html")
    else:
        return render(request,"Admin/Place.html",{"district":dis_data,"data":place_data})


def delete_place(request,plid):
    db.collection("tbl_place").document(plid).delete()
    return redirect("webadmin:place")

def edit_place(request,id):
    dis = db.collection("tbl_district").stream()
    dis_data = []
    for d in dis:
        data =d.to_dict()
        dis_data.append({"dis":data,"id":d.id})
    place=db.collection("tbl_place").document(id).get().to_dict()
    # district=db.collection("tbl_district").document(place['district_id']).get().to_dict()
    
    if request.method == "POST":
        db.collection("tbl_place").document(id).update({"place_name":request.POST.get("txtplace"),
        "place_pin":request.POST.get("txtpin"),"district_id":request.POST.get("seldistrict")})
        return redirect("webadmin:place")
    else:
        return render(request,"Admin/Place.html",{'district':dis_data,'place_data':place})          

#Route
def route(request):
    ro= db.collection("tbl_route").stream()
    route_data = []
    for d in ro :
        data =d.to_dict()
        route_data.append({"ro":data,"id":d.id})
        # dis_data.append({"dis":d.to_dict(),"id":d.id})
  
    if request.method=="POST":
        # tbl_district.objects.create(district_name=request.POST.get('txtdis'))
        db.collection("tbl_route").add({"startroute_name":request.POST.get('txtsroute'),"endroute_name":request.POST.get('txteroute'),"route_rate":request.POST.get('txtrrate')})
        return render(request,"Admin/Route.html")
    else:
        return render(request,"Admin/Route.html",{"route":route_data})

def delete_route(request,rid):
    # tbl_district.objects.get(id=delid).delete()
    db.collection("tbl_route").document(rid).delete()
    return redirect("webadmin:route")        

def edit_route(request,eid):
    dis = db.collection("tbl_route").document(eid).get().to_dict()
    if request.method == "POST":
        dist = request.POST.get('txtroute')
        dis_dict = {"route_name":dist}
        db.collection("tbl_route").document(eid).update(dis_dict)
        return redirect("webadmin:route")
    else:
        return render(request,"Admin/Route.html",{"routes":dis})

#Stop
def stop(request):
  
    route = db.collection("tbl_route").stream()
    route_data = []
    for d in route:
        data = d.to_dict()
        route_data.append({"dis": data, "id": d.id})

    # Fetch stop data with associated route names
    stop = db.collection("tbl_stop").stream()
    print(route_data)
    stop_data = []
    for p in stop:
        stop_dict = p.to_dict()
        route_ref = db.collection("tbl_route").document(stop_dict["route_id"])
        route = route_ref.get().to_dict()
        if route:
            stop_data.append({"place": stop_dict, "id": p.id, "route_name": route})

    if request.method == "POST":
        db.collection("tbl_stop").add({
            "stop_name": request.POST.get('txtstp'),
            "route_id": request.POST.get('selstop'),
            "stop_no": request.POST.get('txtstpno')
        })
        return redirect("webadmin:stop")
    else:
        return render(request, "Admin/Stop.html", {"route": route_data, "stop1": stop_data})

def delete_stop(request,sdid):
    db.collection("tbl_stop").document(sdid).delete()
    return redirect("webadmin:stop")    

#Department       
def dep(request):
    de= db.collection("tbl_department").stream()
    dep_data = []
    for dep1 in de :
        data =dep1.to_dict()
        dep_data.append({"de":data,"id":dep1.id})
    if request.method=="POST":
        db.collection("tbl_department").add({"dep_name":request.POST.get('txtdep')})
        return render(request,"Admin/Department.html")
    else:
        return render(request,"Admin/Department.html",{"d1":dep_data})

def delete_dep(request,depid):
    db.collection("tbl_department").document(depid).delete()
    return redirect("webadmin:dep")         

def adminreg(request):
    if request.method=="POST":
        email = request.POST.get("txtmail")
        password = request.POST.get("txtpass")
        try:
            admin = firebase_admin.auth.create_user(email=email,password=password)
        except (firebase_admin._auth_utils.EmailAlreadyExistsError,ValueError) as error:
            return render(request,"Admin/Adminregistration.html",{"msg":error})
        # tbl_admin.objects.create(admin_name=request.POST.get('txtname'),admin_con=request.POST.get('txtcon'),admin_mail=request.POST.get('txtmail'),admin_pass=request.POST.get('txtpass'))
        Images=request.FILES.get("txtimage")
        if Images:
            path="Admin/Admin_profile/"+Images.name
            sd.child(path).put(Images)
            img_url2=sd.child(path).get_url(None)     
        db.collection("tbl_admin").add({"admin_id":admin.uid,"admin_name":request.POST.get('txtname'),"admin_pic":img_url2, "admin_con":request.POST.get('txtcon'),"admin_mail":request.POST.get('txtmail')})
        return render(request,"Admin/Adminregistration.html")
    else:
        return render(request,"Admin/Adminregistration.html")  

#Course
def course(request):
    admin=db.collection("tbl_admin").document(request.session["aid"]).get().to_dict()

    dep = db.collection("tbl_department").stream()
    dep_data = []
    for d in dep:
        data =d.to_dict()
        dep_data.append({"dep":data,"id":d.id})

    course = db.collection("tbl_course").stream()
    course_data = []
    for p in course:
        course =p.to_dict()
        dep=db.collection("tbl_department").document(course["dep_id"]).get().to_dict()
        course_data.append({"place":course,"id":p.id,"dep_name":dep})    

    if request.method=="POST":
        db.collection("tbl_course").add({"course_name":request.POST.get('txtcourse'), "dep_id":request.POST.get('seldep')})
        return render(request,"Admin/Course.html")
    else:
        return render(request,"Admin/Course.html",{"dep":dep_data,"course":course_data,"admin":admin})  


def delete_course(request,cid):
    db.collection("tbl_course").document(cid).delete()
    return redirect("webadmin:course")  

def homepage(request):
        admin=db.collection("tbl_admin").document(request.session["aid"]).get().to_dict()
        payments_ref1 = db.collection("tbl_student").where("stu_status", "==",0).stream()
        noti=len(list(payments_ref1))
        payments_ref = db.collection("tbl_student").where("stu_status", "==",0).limit(3).stream()
        s_data=[]
        for i in payments_ref:
            data =i.to_dict()
            s_data.append({"stu":data,"id":i.id})

     
        
        return render(request,"Admin/Adminhomepage.html",{"admin":admin,"noti":noti,"sdata":s_data})
   


    
#Admin Profile
def adminprofile(request):
     admin_id = request.session.get("aid")
     if admin_id:
        admin_ref = db.collection("tbl_admin").document(admin_id).get().to_dict()
        return render(request, "Admin/AdminMyprofile.html", {"admin": admin_ref})
     else:
        return render(request, "Admin/AdminMyprofile.html")

def edit_adminprofile(request):
    addata=db.collection("tbl_admin").document(request.session["aid"]).get().to_dict()
    if request.method == "POST":
        Images=request.FILES.get("txtimage1")
        if Images:
            path="User/Driver_photo/"+Images.name
            sd.child(path).put(Images)
            new_url=sd.child(path).get_url(None)
        db.collection("tbl_admin").document(request.session["aid"]).update({"admin_name": request.POST.get('txtname1'),"admin_con":request.POST.get('txtcon1'),"admin_pic":new_url})
        return redirect("webadmin:adminprofile")
    else:
        return render(request,"Admin/AdminEditprofile.html",{"admin":addata})
    

#Bus
def bus(request):
    bo= db.collection("tbl_bus").stream()
    bus_data = []
    for d in bo :
        data =d.to_dict()
        bus_data.append({"bo":data,"id":d.id})
        # dis_data.append({"dis":d.to_dict(),"id":d.id})
  
    if request.method=="POST":
        Images=request.FILES.get("txtbimage")
        if Images:
            path="Bus/Bus_image/"+Images.name
            sd.child(path).put(Images)
            new_url1=sd.child(path).get_url(None)
        # tbl_district.objects.create(district_name=request.POST.get('txtdis'))
        db.collection("tbl_bus").add({"bus_regno":request.POST.get('txtbusno'),"bus_capacity":request.POST.get('txtcapacity'),"bus_image":new_url1,"bus_startingtime":request.POST.get('txtbtime')})
        return render(request,"Admin/Bus.html")
    else:
        return render(request,"Admin/Bus.html",{"bus":bus_data}) 

def delete_bus(request,bid):
    db.collection("tbl_bus").document(bid).delete()
    return redirect("webadmin:bus")  
   
def edit_bus(request, busid):
    dis = db.collection("tbl_bus").document(busid).get().to_dict()

    if request.method == "POST":
        Images=request.FILES.get("txtbimage")
        if Images:
            path="Bus/Bus_image/"+Images.name
            sd.child(path).put(Images)
            new_url2=sd.child(path).get_url(None)
        bus_capacity = request.POST.get('txtcapacity')
        bus_image = request.POST.get('txtbusimage')  # Make sure the input name is correct
        bus_startingtime = request.POST.get('txtbtime')  # Make sure the input name is correct

        # Update the bus_capacity, bus_image, and bus_startingtime in the database
        dis_dict = {"bus_capacity": bus_capacity, "bus_image": new_url2, "bus_startingtime": bus_startingtime}
        db.collection("tbl_bus").document(busid).update(dis_dict)

        return redirect("webadmin:bus")
    else:
        return render(request, "Admin/Bus.html", {"routes": dis})

def verifystudent(request):
    student=db.collection("tbl_student").stream()
    p_data =[]
    for p in student:
        p_data.append({"place":p.to_dict(),"id":p.id})
    return render(request,"Admin/Verifystudent.html",{"pdata":p_data})

def reject_student(request,rejid):
    db.collection("tbl_student").document(rejid).delete()
    return redirect("webadmin:verifystudent")      

def accept_student(request,accid):
    db.collection("tbl_student").document(accid).update({"stu_status": 1})
    student = db.collection("tbl_student").document(accid).get().to_dict()
    email = student['stu_mail']
    # send_mail(
    #         'Reset your password ', #subject
    #         "\r hello",
    #         settings.EMAIL_HOST_USER,
    #         [email],
    #     )    
    send_mail(
        'Welcome to Buslink!',
         f'Dear {student["stu_name"]},\n\n'
        'We are excited to welcome you to Buslink. Your student status has been accepted!\n\n'
        'Thank you for choosing Buslink. If you have any questions or need assistance, feel free to reach out.\n\n'
        'Best regards,\n'
        'The Buslink Team',
        
        settings.EMAIL_HOST_USER,
        [email],
    )                   
    return redirect("webadmin:verifystudent")
   
    
def verifydriver(request):
    driver=db.collection("tbl_driver").stream()
    d_data =[]
    for p in driver:
        d_data.append({"place":p.to_dict(),"id":p.id})
    return render(request,"Admin/Verifydriver.html",{"pdata":d_data})

def reject_driver(request,rejdid):
    db.collection("tbl_driver").document(rejdid).delete()
    return redirect("webadmin:verifydriver")        

def accept_driver(request,accdid):
    db.collection("tbl_driver").document(accdid).update({"driver_status": 1})
    driver = db.collection("tbl_driver").document(accdid).get().to_dict()
    email = driver['driver_mail']
    send_mail(
        'Welcome to Buslink',
        'Dear ' + driver['driver_name'] + ',\n\n'
        'We are excited to welcome you to Buslink.'
        'Thank you for choosing Buslink. If you have any questions or need assistance, feel free to reach out.\n\n'
        'Best regards,\n'
        'The Buslink Team',
        settings.EMAIL_HOST_USER,
        [email],
    )                   
    return redirect("webadmin:verifydriver")    


# def assigndriver(request):
#     assign=db.collection("tbl_assign").stream()
#     bus=db.collection("tbl_bus").stream()
#     driver=db.collection("tbl_driver").stream()
#     route=db.collection("tbl_route").stream()

#     b_data =[]
#     d_data=[]
#     r_data=[]
#     a_data=[]
#     for p in bus:
#         b_data.append({"bus":p.to_dict(),"id":p.id})
#     for d in driver:
#         d_data.append({"driver":d.to_dict(),"id":d.id}) 
#     for r in route:
#         r_data.append({"route":r.to_dict(),"id":r.id})
#     for a in assign:
#         a_data.append({"assign":a.to_dict(),"id":a.id})    

#     if request.method=="POST":
#         db.collection("tbl_assign").add({"bus_id":request.POST.get('selbus'),"driver_id":request.POST.get('seldriver'),"route_id":request.POST.get('selroute')})
#         return render(request,"Admin/Assigndriver.html")
#     else: 
#         return render(request,"Admin/Assigndriver.html",{"data":a_data,"driver":d_data,"route":r_data,"bus":b_data})    





def assigndriver(request):
    assign=db.collection("tbl_assign").get()
    print(len(assign))
    bus=db.collection("tbl_bus").stream()
    driver=db.collection("tbl_driver").stream()
    route=db.collection("tbl_route").stream()
    a_data=[]
    b_data =[]
    d_data=[]
    r_data=[]
    for p in bus:
        b_data.append({"bus":p.to_dict(),"id":p.id})
    for d in driver:
        d_data.append({"driver":d.to_dict(),"id":d.id}) 
    for r in route:
        r_data.append({"route":r.to_dict(),"id":r.id})
    for a in assign:
        assignData = a.to_dict()
        drivername = getDriver(assignData['driver_id'])
        bus_name=getBus(assignData['bus_id'])
        routedata=getRoute(assignData['route_id'])
        print(routedata)
        a_data.append({"assign":a.to_dict(),"id":a.id, "driver_name": drivername,"bus_name":bus_name,"route_name":routedata})    
    if request.method=="POST":
        db.collection("tbl_assign").add({"bus_id":request.POST.get('selbus'),"driver_id":request.POST.get('seldriver'),"route_id":request.POST.get('selroute')})
        return render(request,"Admin/Assigndriver.html")
    else: 
        return render(request,"Admin/Assigndriver.html",{"data":a_data,"driver":d_data,"route":r_data,"bus":b_data})  


def getDriver(id):
    DriverDetails = db.collection("tbl_driver").document(id).get().to_dict()
    return DriverDetails['driver_name']

def getBus(id):
    BusDetails = db.collection("tbl_bus").document(id).get().to_dict()
    return BusDetails['bus_regno']

def getRoute(id):
    RouteDetails = db.collection("tbl_route").document(id).get().to_dict()
    data = {
            'endroute_name':RouteDetails['endroute_name'],
            'startroute_name': RouteDetails['startroute_name']
    }
    return data     
    
   

def changerequest(request):
    student=db.collection("tbl_student").stream()
    stp=db.collection("tbl_stdstp").stream()
    p_data =[]
    s_data=[]
    for p in student:
        p_data.append({"place":p.to_dict(),"id":p.id})
    for p1 in stp:
        s_data.append({"place1":p1.to_dict(),"id":p1.id})    
    return render(request,"Admin/Routechangerequest.html",{"pdata":p_data,"ndata":s_data}) 

def request_accept(request,changeid):
    db.collection("tbl_     ").document(changeid).update({"stdstp_status": 2})
    driver = db.collection("tbl_stdstp").document(changeid).get().to_dict()  
    return redirect("webadmin:changerequest")   

def request_reject(request,rejectid):
    db.collection("tbl_stdstp").document(rejectid).delete()
    return redirect("webadmin:changerequest")             

def viewcomplaints(request):
    ccompdata=db.collection("tbl_complaints").where("driver_id","!=",0).stream()
    ccomplist=[]
    for i in ccompdata:
        comp=i.to_dict()
        center=db.collection("tbl_driver").document(comp["driver_id"]).get().to_dict()
        ccomplist.append({"ccomp_data":comp,"id":i.id,"center":center})

    ccompdata=db.collection("tbl_complaints").where("stu_id","!=",0).stream()
    ccomplist2=[]
    for i in ccompdata:
        comp=i.to_dict()
        user=db.collection("tbl_student").document(comp["stu_id"]).get().to_dict()
        ccomplist2.append({"ccomp_data":comp,"id":i.id,"user":user})
    return render(request,"Admin/ViewComplaints.html",{"data":ccomplist,"data2":ccomplist2})

def replycomplaints(request,id):
    if request.method=="POST":
        db.collection("tbl_complaints").document(id).update({"complaint_reply":request.POST.get("txtreply")})
        return redirect("webadmin:viewcomplaints")
    else:
        return render(request,"Admin/Replaycomplaints.html")

def viewfeedbacks(request):
    feeddata=db.collection("tbl_feedbacks").where("driver_id","!=",0).stream()
    feedlist1=[]
    for i in feeddata:
        feed=i.to_dict()
        center=db.collection("tbl_driver").document(feed["driver_id"]).get().to_dict()
        feedlist1.append({"cfeed_data":feed,"id":i.id,"center":center})

    feeddata=db.collection("tbl_feedbacks").where("stu_id","!=",0).stream()
    feedlist2=[]
    for i in feeddata:
        feed=i.to_dict()
        user=db.collection("tbl_student").document(feed["stu_id"]).get().to_dict()
        feedlist2.append({"ufeed_data":feed,"id":i.id,"user":user})    
    return render(request,"Admin/ViewFeedbacks.html",{"data":feedlist1,"data2":feedlist2})
    



          