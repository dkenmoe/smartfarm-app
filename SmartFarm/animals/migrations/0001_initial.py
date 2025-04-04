# Generated by Django 5.1.7 on 2025-03-19 18:03

import django.db.models.deletion
from django.conf import settings
from django.db import migrations, models


class Migration(migrations.Migration):

    initial = True

    dependencies = [
        migrations.swappable_dependency(settings.AUTH_USER_MODEL),
    ]

    operations = [
        migrations.CreateModel(
            name='FeedingRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=100)),
                ('type', models.CharField(choices=[('food', 'Food'), ('water', 'Water'), ('medicine', 'Medicine')], max_length=50)),
                ('stock_quantity', models.FloatField()),
            ],
        ),
        migrations.CreateModel(
            name='AnimalBreed',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50)),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='AnimalType',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('name', models.CharField(max_length=50, unique=True)),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='AnimalGroup',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gender', models.CharField(choices=[('male', 'Male'), ('female', 'Female')], max_length=10)),
                ('quantity', models.IntegerField()),
                ('birth_date', models.DateField()),
                ('weight', models.FloatField()),
                ('breed', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='animal_groups', to='animals.animalbreed')),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, related_name='animal_groups', to=settings.AUTH_USER_MODEL)),
                ('animal_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='animal_groups', to='animals.animaltype')),
            ],
        ),
        migrations.AddField(
            model_name='animalbreed',
            name='animal_type',
            field=models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='breeds', to='animals.animaltype'),
        ),
        migrations.CreateModel(
            name='HealthRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('checkup_date', models.DateField(auto_now_add=True)),
                ('diagnosis', models.TextField()),
                ('treatment', models.TextField()),
                ('veterinarian', models.CharField(max_length=100)),
                ('animal', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='health_records', to='animals.animalgroup')),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='WeightCategory',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('min_weight', models.FloatField()),
                ('max_weight', models.FloatField()),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
            ],
        ),
        migrations.CreateModel(
            name='DiedRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], max_length=10)),
                ('quantity', models.PositiveIntegerField()),
                ('date_of_death', models.DateField(auto_now_add=True)),
                ('animal_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='died_records', to='animals.animaltype')),
                ('breed', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='died_records', to='animals.animalbreed')),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('weight_category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='died_records', to='animals.weightcategory')),
            ],
        ),
        migrations.CreateModel(
            name='BirthRecord',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], max_length=10)),
                ('quantity', models.PositiveIntegerField()),
                ('date_of_birth', models.DateField(auto_now_add=True)),
                ('animal_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='birth_records', to='animals.animaltype')),
                ('breed', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='birth_records', to='animals.animalbreed')),
                ('created_by', models.ForeignKey(null=True, on_delete=django.db.models.deletion.SET_NULL, to=settings.AUTH_USER_MODEL)),
                ('weight_category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='birth_records', to='animals.weightcategory')),
            ],
        ),
        migrations.AddField(
            model_name='animalgroup',
            name='weight_category',
            field=models.ForeignKey(blank=True, null=True, on_delete=django.db.models.deletion.SET_NULL, to='animals.weightcategory'),
        ),
        migrations.CreateModel(
            name='AnimalPrice',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('price', models.DecimalField(decimal_places=2, max_digits=10)),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], max_length=10)),
                ('created_by', models.DateField(auto_now_add=True)),
                ('breed', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prices', to='animals.animalbreed')),
                ('animal_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prices', to='animals.animaltype')),
                ('weight_category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='prices', to='animals.weightcategory')),
            ],
            options={
                'unique_together': {('animal_type', 'weight_category')},
            },
        ),
        migrations.CreateModel(
            name='AnimalInventory',
            fields=[
                ('id', models.BigAutoField(auto_created=True, primary_key=True, serialize=False, verbose_name='ID')),
                ('gender', models.CharField(choices=[('Male', 'Male'), ('Female', 'Female')], max_length=10)),
                ('quantity', models.PositiveIntegerField(default=0)),
                ('breed', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventories', to='animals.animalbreed')),
                ('animal_type', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventories', to='animals.animaltype')),
                ('weight_category', models.ForeignKey(on_delete=django.db.models.deletion.CASCADE, related_name='inventories', to='animals.weightcategory')),
            ],
            options={
                'unique_together': {('animal_type', 'breed', 'gender', 'weight_category')},
            },
        ),
    ]
