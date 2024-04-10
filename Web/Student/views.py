from django.shortcuts import render
from django.shortcuts import render,redirect
from Guest.models import *
from Admin import views
from Student.models import*
from BusLink.settings import *
from django.core.mail import send_mail
from django.conf import settings
from django.contrib import messages
from datetime import datetime
from io import BytesIO
from django.shortcuts import render
from django.http import HttpResponse
from django.core.mail import EmailMessage
from reportlab.lib import colors
from reportlab.platypus import Table, TableStyle
from reportlab.lib.units import inch

from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
# from django.shortcuts import render,redirect
# import firebase_admin
# from firebase_admin import storage,auth,firestore,credentials
# import pyrebase

# Create your views here.
def stuhomepage(request):       
    student=db.collection("tbl_student").document(request.session["sid"]).get().to_dict()
    current_year = datetime.now().year
    current_datetime = datetime.now()
    current_month = current_datetime.month
    print(current_month)

    months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
    ]
    context = []
    for month in months:
        payments_ref = db.collection("tbl_payment").where("stu_id", "==", request.session['sid']).where("pay_month", "==", month).stream()
        if len(list(payments_ref)) > 0:
            status = "1"
        else:
            status = "0"

        if months.index(month) + 1 > current_month:
            status = "2"    
          
        context.append({"month": month, "status": status, "current_month ":current_month  })

    return render(request,"Student/Studenthomepage.html",{"student":student,'context':context})

def changepassword(request):
        user = db.collection("tbl_student").document(request.session["sid"]).get().to_dict()
        email = user['stu_mail']
        # print(email)
        em_link = firebase_admin.auth.generate_password_reset_link(email)
        send_mail(
            'Reset your password ', #subject
            "\rHello \r\nFollow this link to reset your Project password for your " + email + "\n" + em_link +".\n If you didn't ask to reset your password, you can ignore this email. \r\n Thanks. \r\n Your D MARKET team.",#body
            settings.EMAIL_HOST_USER,
            [email],
        )              
        return redirect("webstudent:studentprofile")  

#STUDENT PROFILE

def studentprofile(request):
    student_id = request.session.get("sid")
    if student_id:
        student_ref = db.collection("tbl_student").document(student_id).get().to_dict()
        return render(request,"Student/StudentMyprofile.html",{"student": student_ref})
    else:
        return render(request,"Student/StudentMyprofile.html")   


def edit_studentprofile(request):
    addata=db.collection("tbl_student").document(request.session["sid"]).get().to_dict()
    if request.method == "POST":
        Images=request.FILES.get("txtimage2")
        if Images:
            path="User/Student_photo/"+Images.name
            sd.child(path).put(Images)
            new_url=sd.child(path).get_url(None)
            db.collection("tbl_student").document({"stu_img":new_url})
        db.collection("tbl_student").document(request.session["sid"]).update({"stu_name": request.POST.get('txtname2'),"stucon":request.POST.get('txtcon2')})
        return redirect("webstudent:studentprofile")
    else:
        return render(request,"Student/Studenteditprofile.html",{"student":addata})        




def choosestop(request):
    

    ro = db.collection("tbl_route").stream()
    stdstp = db.collection("tbl_stdstp").stream()

    result = db.collection("tbl_stdstp").where("stu_id", "==", request.session.get("sid")).stream()

    stopdata = []
    if result is not None:
        for doc in result:
            i = doc.to_dict()
            stdstp_status = doc.get("stdstp_status")
            student_doc = db.collection("tbl_student").document(i["stu_id"]).get()
            if student_doc.exists:
                student = student_doc.to_dict()
            else:
                student = {}
            stop_doc = db.collection("tbl_stop").document(i["stop_id"]).get()
            if stop_doc.exists:
                stop = stop_doc.to_dict()
                route_id = stop.get("route_id")
                if route_id:
                    route_doc = db.collection("tbl_route").document(route_id).get()
                    if route_doc.exists:
                        route = route_doc.to_dict()
                    else:
                        route = {}
                else:
                    route = {}
            else:
                stop = {}
                route = {}
            stopdata.append({"data": doc.to_dict(), "student": student, "stop": stop, "route": route, "id": doc.id, "stdstp_status": stdstp_status})

    route_data = [{"stp": d.to_dict(), "id": d.id} for d in ro]
    stdstp_data = [{"stp1": d1.to_dict(), "id": d1.id} for d1 in stdstp]

    if request.method == "POST":
        stop_id = request.POST.get('sel_stop')
        if stop_id:
            db.collection("tbl_stdstp").add({"stu_id": request.session.get("sid"), "stop_id": stop_id, "stdstp_status": 0})
            return redirect("webstudent:choosestop")
        else:
            # Handle the case where stop_id is not provided in the form
            pass

    return render(request, "Student/Choosestop.html", {"route": route_data, "d1data": stdstp_data, "stopdata": stopdata})
       
def ajax_stop(request):
    place=db.collection("tbl_stop").where("route_id", "==", request.GET.get('did')).stream()
    pla_data =[]
    for p in place:
        pla_data.append({"place":p.to_dict(),"id":p.id})
    return render(request,"Student/AjaxStop.html",{"pdata":pla_data})  

def editchoosestop(request,csdid): 
    s1= db.collection("tbl_stdstp").stream()
    stdstp_data1=[]
    for d3 in s1:
        data3 =d3.to_dict()
        stdstp_data1.append({"stp":data3,"id":d3.id})
    db.collection("tbl_stdstp").document(csdid).update({"stdstp_status": 1}) 
    return redirect("webstudent:choosestop")

def stucomplaint(request):
    id=request.session["sid"]

    compdata=db.collection("tbl_complaints").where("stu_id", "==", request.session["sid"]).stream()
    complist=[]
    for i in compdata:
        comp=i.to_dict()
        complist.append({"comp_data":comp,"id":i.id})
        
    if request.method=="POST":
        data={"complaint_title":request.POST.get("txttitle")
            ,"complaint_content":request.POST.get("txtccontent"),"stu_id":id,"driver_id":0}
        db.collection("tbl_complaints").add(data)
        return redirect("webstudent:stucomplaint")
    else:
        return render(request,"Student/Stucomplaint.html",{"data":complist})

def stufeedback(request):
    id=request.session["sid"]

    compdata=db.collection("tbl_feedbacks").where("stu_id", "==", request.session["sid"]).stream()
    complist=[]
    for i in compdata:
        comp=i.to_dict()
        complist.append({"comp_data":comp,"id":i.id})
        
    if request.method=="POST":
        data={"feedback_content":request.POST.get("txtfscontent"),
        "feedback_time":datetime.now(),
           "stu_id":id,"driver_id":0}
        db.collection("tbl_feedbacks").add(data)
        return redirect("webstudent:stuhomepage")
    else:
        return render(request,"Student/Studentfeedbacks.html",{"data":complist})

def stupayment(request):
    route_rate = request.GET.get('amount','')
    month = request.GET.get('month', '') 
    
    de = db.collection("tbl_payment").stream()
    
    dep_data = []
    for dep1 in de:
        data = dep1.to_dict()
        dep_data.append({"de": data, "id": dep1.id,'month': month,"route_rate":route_rate})
    
    if request.method == "POST":
        db.collection("tbl_payment").add({
            "stu_id": request.session["sid"],
            "pay_datetime": datetime.now(),
            "pay_amount": route_rate,
            "pay_status": 0,
            "pay_month":month,  # Assuming 'jan' is a string representing the month
            # "bill_no": 7878
        })
        return redirect("webstudent:paymentloading") 
  
    return render(request, "Student/Payment.html", {"d1": dep_data})

   





# def generate_pdf(request):
#     buffer = BytesIO()
#     pdf = canvas.Canvas(buffer, pagesize=letter)
    
#     # Set border dimensions and position
#     border_width = 20
#     page_width, page_height = letter
#     content_width = page_width - 2 * border_width
#     content_height = page_height - 2 * border_width
    
#     # Draw border
#     pdf.setStrokeColorRGB(0, 0, 0)  # Black color
#     pdf.rect(border_width, border_width, content_width, content_height)
    
#     # Add content inside the border
#     pdf.drawString(border_width + 50, page_height - 50, "Welcome to Baselios Poulos II Catholicos College Piravom")
    
#     pdf.save()
#     buffer.seek(0)
#     # Generate HTTP response with the PDF content
#     response = HttpResponse(content_type='application/pdf')
#     response['Content-Disposition'] = 'inline; filename="BusBill.pdf"'  # Display PDF in browser
#     response.write(buffer.getvalue())
#return response
# def payment_card1(request):
#     current_year = datetime.now().year
#     current_datetime = datetime.now()
#     current_month = current_datetime.month
#     print(current_month)
#     payments_ref = db.collection("tbl_payment").where("stu_id", "==", request.session['sid']).stream()
#     payments = []
#     for payment_doc in payments_ref:
#         payment_data = payment_doc.to_dict()
#         payments.append({"payment_data":payment_data})
        
       
#     print(payments)
#     months = [
#         "January", "February", "March", "April", "May", "June",
#         "July", "August", "September", "October", "November", "December"
#     ]
#     context = {
#         'months': enumerate(months),
#         'year': current_year,
#         'payments': payments,
#         'current_month':current_month,

#           # Pass payments data to the template
#     }
#     # print(context)
#     return render(request, "Student/Paymentcard.html","Student/Studenthomepage.html", context)


def payment_card(request):
    current_year = datetime.now().year
    current_datetime = datetime.now()
    current_month = current_datetime.month
    print(current_month)

    months = [
    "January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
    ]
    context = []
    for month in months:
        payments_ref = db.collection("tbl_payment").where("stu_id", "==", request.session['sid']).where("pay_month", "==", month).stream()
        if len(list(payments_ref)) > 0:
            status = "1"
        else:
            status = "0"

        if months.index(month) + 1 > current_month:
            status = "2"    
          
        context.append({"month": month, "status": status, "current_month ":current_month  })
    print(context)
    return render(request, "Student/Paymentcard.html",{'context':context})


def paymentinfo(request):
    complist = []  # Initialize the complist before appending data to it
    month = request.GET.get('month', '') 
    route_rate=request.GET.get('route_rate','') 
    result = db.collection("tbl_stdstp").where("stu_id", "==", request.session.get("sid")).stream()
    for doc in result:
        comp = doc.to_dict() 
        bdata_doc = db.collection("tbl_stop").document(comp["stop_id"]).get()
        bdata = bdata_doc.to_dict()
        rdata_doc = db.collection("tbl_route").document(bdata["route_id"]).get()
        rdata = rdata_doc.to_dict()
        complist.append({
                "comp_data": comp,
                "bdata": bdata,
                "rdata": rdata,
                "id": doc.id
            })
        print(bdata)
    current_date = datetime.now().strftime("%d %B, %Y")
    context = {'current_date': current_date, 'complist': complist,'month': month ,'route_rate' : route_rate}  # Include complist in the context dictionary
    if request.method == "POST":
        return render(request, "Student/PaymentInfo.html", {'month':month,'amount':request.POST.get('route_rate')},)
    return render(request, "Student/PaymentInfo.html", context,)

def paymentloading(request):
    return render(request,"Student/Paymentloading.html")



def success(request):
    buffer = BytesIO()
    pdf = canvas.Canvas(buffer, pagesize=letter)

# Set border dimensions and position
    border_width = 20
    page_width, page_height = letter
    content_width = page_width - 2 * border_width
    content_height = page_height - 2 * border_width

# Draw border
    pdf.setStrokeColorRGB(0, 0, 0)  # Black color
    pdf.rect(border_width, border_width, content_width, content_height)

# Add content inside the border
    pdf.drawString(border_width + 50, page_height - 50, "Welcome to Baselios Poulos II Catholicos College Piravom")

# Create data for the table (replace with actual data from your database)
    table_data = [
    ['Route Name', 'Stop Name', 'Month', 'Amount'],
    ['Route 1', 'Stop A', 'January', '$100'],
    ]

# Create the table and set its style
    table = Table(table_data, colWidths=[2 * inch, 2 * inch, 1.5 * inch, 1 * inch])
    table.setStyle(TableStyle([('BACKGROUND', (0, 0), (-1, 0), colors.gray),
                           ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
                           ('ALIGN', (0, 0), (-1, -1), 'CENTER'),
                           ('INNERGRID', (0, 0), (-1, -1), 0.25, colors.black),
                           ('BOX', (0, 0), (-1, -1), 0.25, colors.black)]))

# Add the table to the PDF
    table.wrapOn(pdf, content_width, content_height)
    table.drawOn(pdf, border_width, border_width + 100)

# Save the PDF buffer
    pdf.save()
    buffer.seek(0)

# Assuming db is your Firestore database instance
    student = db.collection("tbl_student").document(request.session["sid"]).get().to_dict()
    email = student['stu_mail']

# Send the PDF as an email attachment
    email = EmailMessage(
    'PDF Attachment',
    'Please find the attached PDF.',
    'collegebusmanagementsystem@gmail.com',
    [email],
    )
    email.attach('BusBill.pdf', buffer.getvalue(), 'application/pdf')
    email.send()
    return render(request,"Student/Success.html")    

