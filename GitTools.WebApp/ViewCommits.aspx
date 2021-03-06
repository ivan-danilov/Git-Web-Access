﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="ViewCommits.aspx.cs" Inherits="GitTools.WebApp.ViewCommits" %>
<asp:Content ID="Content1" ContentPlaceHolderID="HeadContent" runat="server">
    <script type="text/javascript" src="Scripts/jquery-1.5.min.js"></script>
    <script type="text/javascript" src="Scripts/jQuery.tmpl.min.js"></script>
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="MainContent" runat="server">
<h2 id="title"></h2>
<div style="float:left;margin-top:15px">
    <canvas id="canvas" width="120" height="1000"></canvas>
</div>
<ul id="nodeList" style="list-style-type: none; font:16px/24px arial"></ul>

<script id="nodeTemplate" type="text/x-jquery-tmpl"> 
<li><span class="branch">${Branches}</span><span class="tag">${Tags}</span> <a href="#${Id}">${Message}</a></li>
</script>

<script type="text/javascript">
    var repo = '<%= Request["name"] %>';
    var ctx = $("#canvas")[0].getContext('2d'); ;
    var nodes;
    var links;

    $(function () {

        $("#title").text(repo);

        $.ajaxSetup({
            contentType: "application/json; charset=utf-8",
            dataType: "json"
        });

        $.ajax({
            url: "odata/RepositoryGraph('" + repo + "')/Nodes?$top=18&$orderby=Y",
            success: function (data) {
                nodes = data.d;
                $.ajax({
                    url: "odata/RepositoryGraph('" + repo + "')/Links",
                    success: function (data) {
                        links = data.d;
                        draw(nodes, links);
                    },
                    error: function (xhr) { alert(xhr.responseText); }
                });

            },
            error: function (xhr) { alert(xhr.responseText); }
        });


    });

    var h = 24;
    var w = 16;
    var r = 5;

    function draw(nodes, links) {
        var ww = 0
        for (var i = 0; i < nodes.length; i++) {
            if (nodes[i].X > ww) ww = nodes[i].X;
        }
        ctx.canvas.width = (ww + 2) * w;
        ctx.canvas.height = nodes.length * h;
        drawLinks(links);
        drawNodes(nodes);
        $("#nodeTemplate").tmpl(nodes).appendTo("#nodeList");
        //alert(nodes.length * h);
    }

    function drawNodes(nodes) {

        for (var i = 0; i < nodes.length; i++) {
            var node = nodes[i];
            var x = node.X * w + w / 2;
            var y = node.Y * h + h / 2;

            ctx.fillStyle = "#ff8080";
            ctx.beginPath();
            ctx.arc(x, y, r, 0, Math.PI * 2, true);
            ctx.fill();
            ctx.closePath();

            node.Id = node.Id.substring(0, 5);
            //            ctx.fillStyle = "#333";
            //            ctx.font = "14px Arial";
            //            ctx.fillText(node.Message, 80, y + 4);
        }
    }


    function drawLinks(links) {

        ctx.lineWidth = 1;
        ctx.strokeStyle = "#808080";

        for (var i = 0; i < links.length; i++) {

            var link = links[i];
            var x1 = link.X1 * w + w / 2;
            var y1 = link.Y1 * h + h / 2;
            var x2 = link.X2 * w + w / 2;
            var y2 = link.Y2 * h + h / 2;
            var y3 = (link.Y2 - 1) * h + h / 2;

            if (link.X1 == link.X2) {
                ctx.moveTo(x1, y1);
                ctx.lineTo(x2, y2);
            }
            else {
                ctx.moveTo(x1, y1);
                ctx.lineTo(x1, y3);
                ctx.bezierCurveTo(x1, y2, x2, y3, x2, y2);
            }
            ctx.stroke();
        }
    }

</script>

</asp:Content>
