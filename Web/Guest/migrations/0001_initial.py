# Generated by Django 5.0 on 2024-01-05 05:46

import django.db.models.deletion
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        ('Admin', '0005_tbl_subcategory'),
    ]

    operations = [
        migrations.CreateModel(
            name='Student',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('student_name', models.CharField(max_length=50)),
                ('student_con', models.CharField(max_length=50)),
                ('student_mail', models.CharField(max_length=50)),
                ('student_gender', models.CharField(max_length=50)),
                ('student_address', models.CharField(max_length=90)),
                ('student_photo', models.CharField(max_length=100)),
                ('student_proof', models.CharField(max_length=100)),
                ('student_pass', models.CharField(max_length=50)),
                ('place', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, to='Admin.tbl_district')),
            ],
        ),
    ]
