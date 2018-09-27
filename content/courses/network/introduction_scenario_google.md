---
title: "Network introduction - scenario google"
description: ""
date: 2018-09-24
githubIssueID: 0
tags: [""]
draft: true
---

## Authors

- [Grégoire MOLVEAU](/authors/gmolveau/)
- [Gwendal POIRE](/authors/gpoire/)

---

## Table of contents

(copy your markdown in https://ecotrust-canada.github.io/markdown-toc/) and paste here

---

## Introduction

This courte aims to explain brievly some well known network protocols. To illustrate, we will use the following scenario :

- a computer is turned on, then it requests google.com.

Pretty simple but a lot of things is happening under the hood.

Here's the schema of our network :
- 2 PCs ; 1 switch ; 1 router ; 1 DHCP server ; Internet ; 1 DNS server ; Google.com

![network schema](/img/courses/network/network_schema.png)

### Concepts

- DHCP
- IP
- DNS
- NAT
- HTTP

## OSI model

Open Systems Interconnection (OSI) was introduced in 1978.

What's better than the official description ? 

> "a series of protocol layers with a specific set of functions allocated to each layer. Each layer offers specific services to higher layers while shielding these layers from the details of how the services are implemented. A well-defined interface between each pair of adjacent layers defines the services offered by the lower layer to the higher one and how those services are accessed."

![osi model microsoft](https://docs.microsoft.com/en-us/windows-hardware/drivers/network/images/101osi.png)
![osi model](/img/courses/network/osi_model.png)

A way to simplify this model is to create a 5-layer model. `Application + Presentation + Session` becomes only `Application`.

![5 layers network model](http://static.filmannex.com/users/galleries/302479/302479_gallery_53ca4893f146a_jpg_fa_rszd.jpg)

### Physical Layer (1)

The physical layer is the lowest layer of the OSI model. This layer manages the reception and transmission of the unstructured raw bit stream over a physical medium. It describes the electrical/optical, mechanical, and functional interfaces to the physical medium. The physical layer carries the signals for all of the higher layers.

- Equipments : 
  - Hub
  - RJ45 ethernet cable

### Data Link layer (2)

This layer was designed to create `frames` (splitting), to transmit (via physical address) and to manage errors (via the CRC algorythm).

- Concepts :
  - fragmentation / splitting
- Protocols :
  - MAC
- Equipments :
  - Level 2 Switch

### Network Layer (3)

This layer provides `routing` and indeed interconnexion between network. The equipment link to this layer is the router (sorry no french shitty word this time). Here we don't talk about frames but packet. a packet of data can be routed across several layer 2 networks 

- Equipments :
	- Router
- Protocols :
	- IP

### Transport Layer (4)
It provides end-to-end commmunication between two hosts. Transport layer also provides the acknowledgement of the successful data transmission and re-transmits the data if error is found.

### Session Layer (5)
### Presentation Layer (6)
### Application Layer (7)




## Booting the computer

### 

  - IP
  - DHCP



## Requesting google website

  - NAT
  - DNS
  - HTTP

## Conclusion

### Going further

### Resources