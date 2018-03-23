---
title: Development Overview
tags: [getting_started, development]
summary: This page provides a quick overview of development environment setup and configuration
---

## Prerequisites

Git, Java 1.8, Maven 3.x

## Clone the Repository

<a class="btn btn-success" style="width: 220px;" href="https://github.com/{{ site.repository }}/" role="button" target="_blank"><i class="fa fa-github fa-lg"></i> DataWave Repo</a>

<div markdown="span" class="alert alert-info" role="alert"><i class="fa fa-info-circle"></i> <b>Note:</b> Your source code
root directory will be referred to as **DW_HOME** from this point forward</div>

## Build DataWave

See the **DW_HOME/BUILDME.md** file for basic build instructions 

## Configuring DataWave for Deployment

To configure DataWave for a specific runtime environment, the build utilizes standard Maven *properties* and *resource
filtering* to perform interpolation of values within configuration files and scripts throughout the project.

### Maven Plugin: read-properties

By convention, the DataWave build will leverage the **datawave:read-properties** plugin to read in these Maven properties
from *\*.properties* files that are found at certain predefined locations. Moreover, the *\*.properties* files for a given
runtime environment are typically specified by (and activated by) a distinct Maven profile that is defined for that
environment.

The *read-properties* plugin source is in *DW_HOME/contrib/read-properties* and will need to be built/installed prior
to your first DataWave build.

The *read-properties* config and *dev* profile from *DW_HOME/pom.xml* below demonstrates the setup...  
```xml
  ...
  <pluginManagement>
     <plugins>
        ...    
        <plugin>
           <groupId>datawave</groupId>
           <artifactId>read-properties</artifactId>
           <version>2.0.1</version>
           <configuration>
               <quiet>true</quiet>
               <directories combine.children="append">
                   <file>${datawave.root}/properties</file>
                   <file>${user.home}/.m2/datawave/properties</file>
               </directories>
               <files combine.children="append">
                   <file>default.properties</file>
               </files>
           </configuration>
           <executions>
              <execution>
                 <id>read-properties</id>
                 <goals>
                    <goal>read-properties</goal>
                 </goals>
                 <phase>validate</phase>
              </execution>
           </executions>
        </plugin>
        ...
     </plugins>
  </pluginManagement>
  <plugins>
     ...
     <plugin>
        <groupId>datawave</groupId>
        <artifactId>read-properties</artifactId>
     </plugin>
     ...
  </plugins>
  ...
  <profiles>
     ...
     <profile>
        <id>dev</id>
        ...
        <build>
           <pluginManagement>
              <plugins>
                 <plugin>
                    <groupId>datawave</groupId>
                    <artifactId>read-properties</artifactId>
                    <configuration>
                       <files>
                          <file>dev.properties</file>
                          <file>dev-passwords.properties</file>
                       </files>
                    </configuration>
                 </plugin>
              </plugins>
           </pluginManagement>
        </build>
     </profile>
     ...
  </profiles>
  ...
```

