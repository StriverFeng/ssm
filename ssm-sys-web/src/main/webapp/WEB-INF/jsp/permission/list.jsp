<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="shiro" uri="http://shiro.apache.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html>
<head>
    <title>权限管理</title>
    <style type="text/css">
        div.wrapper {
            padding: 5px;
            margin: auto;
        }

        table.dataTable thead th.dt-left,
        table.dataTable tbody td.dt-left {
            text-align: left;
        }

        table.dataTable thead th.dt-center,
        table.dataTable tbody td.dt-center {
            text-align: center;
        }

        table.dataTable thead th.dt-right,
        table.dataTable tbody td.dt-right {
            text-align: right;
        }

        table.dataTable tbody td.dt-nowrap {
            max-width: 120px;
            white-space: nowrap;
            text-overflow: ellipsis;
            overflow-x: hidden;
            cursor: pointer;
        }
    </style>
</head>
<body>
<div class="wrapper">
    <div class="panel panel-primary">
        <div class="panel-heading">
            <h5 class="panel-title">资源列表</h5>
        </div>
        <div class="panel-body">
            <div class="table-responsive">
                <table id="table" class="table table-hover table-condensed" cellspacing="0" width="100%">
                    <thead>
                    <tr>
                        <th>资源名称</th>
                        <th>资源类型</th>
                        <th>资源编码</th>
                        <th>资源地址</th>
                        <th>资源状态</th>
                        <th>排序号</th>
                        <th>资源图标</th>
                        <th>上级资源</th>
                    </tr>
                    </thead>
                    <tfoot>
                    <tr>
                        <td colspan="8" class="text-danger">
                            <i class="glyphicon glyphicon-warning-sign"></i> 注意：执行删除操作时，若所选择菜单下存在子菜单，则子菜单也会一并删除。
                        </td>
                    </tr>
                    </tfoot>
                </table>
            </div>
        </div>
    </div>
</div>

<script id="template" type="text/x-handlebars-template">
    <div class="modal fade">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header bg-primary">
                    <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
                    <label class="modal-title">{{title}}</label>
                </div>
                <div class="modal-body">
                    <iframe class="embed-responsive-item" frameborder="0" style="width:100%;height:75vh;display:block;"></iframe>
                </div>
            </div>
        </div>
    </div>
</script>

<script type="text/javascript">

    require([
        'jquery',
        'noty',
        'handlebars',
        'bootstrap',
        'datatables.net',
        'datatables.net-bs',
        'datatables.net-buttons',
        'datatables.net-buttons-bs',
        'datatables.net-buttons-colVis',
        'datatables.net-select',
        'fancybox'
    ], function ($, noty, Handlebars) {

        var template = Handlebars.compile($('#template').html());

        $.extend($.fn.dataTable.ext.buttons, {
            reload: {
                text: 'Reload',
                action: function (e, dt, node, config) {
                    dt.ajax.reload();
                }
            }
        });

        var $table = $('#table').DataTable({
            info: false,
            paging: false,
            ordering: false,
            lengthChange: false,
            searching: true,
            rowId: 'id',
            select: {
                style: 'single' // {none, single, multi, os}
            },
            buttons: [
                {
                    enabled: true,
                    text: '<i class="fa fa-plus"></i>',
                    name: 'add',
                    className: 'btn-sm',
                    titleAttr: 'Click To Add',
                    action: function () {
                        $(template({
                            title: '权限管理-新增'
                        })).insertBefore('#template').modal({
                            backdrop: 'static',
                            show: true
                        }).on('hidden.bs.modal', function () {
                            $(this).remove();
                            $table.ajax.reload();
                        }).find('iframe').attr({
                            src: '${contextPath}/permission/add'
                        });
                    }
                },
                {
                    enabled: false,
                    text: '<i class="fa fa-edit"></i>',
                    name: 'edit',
                    className: 'btn-sm',
                    titleAttr: 'Click To Edit',
                    action: function () {
                        var id = $table.row({selected: true}).id();
                        $(template({
                            title: '权限管理-更新'
                        })).insertBefore('#template').modal({
                            backdrop: 'static',
                            show: true
                        }).on('hidden.bs.modal', function () {
                            $(this).remove();
                            $table.ajax.reload();
                        }).find('iframe').attr({
                            src: '${contextPath}/permission/edit?id=' + id
                        });
                    }
                },
                {
                    enabled: false,
                    text: '<i class="fa fa-trash"></i>',
                    name: 'delete',
                    className: 'btn-sm',
                    titleAttr: 'Click To Delete',
                    action: function () {
                        noty.confirm('确认删除吗?', function (yes) {
                            if (yes) {
                                var id = $table.row({selected: true}).id();
                                $.ajax({
                                    url: '${contextPath}/permission/deleteSubmit',
                                    type: 'POST',
                                    data: {id: id},
                                    dataType: 'json',
                                    success: function (result) {
                                        $table.ajax.reload(function () {
                                            noty.message(result.message, result.success);
                                            $table.buttons(['edit:name', 'delete:name']).enable(!result.success);
                                        });
                                    }
                                });
                            }
                        });
                    }
                },
                {
                    extend: 'reload',
                    enabled: true,
                    text: '<i class="fa fa-refresh"></i>',
                    name: 'reload',
                    className: 'btn-sm',
                    titleAttr: 'Click To Reload'
                },
                {
                    extend: 'colvis',
                    enabled: true,
                    text: '<i class="fa fa-columns"></i>',
                    name: 'colvis',
                    className: 'btn-sm',
                    titleAttr: 'Click To Hidden Column'
                }
            ],
            ajax: {
                url: '${contextPath}/permission/getList',
                type: 'POST',
                contentType: 'application/json',        // 发送信息至服务器时内容编码类型
                dataType: 'json',                       // 预期服务器返回的数据类型
                dataSrc: function (data) {
                    // console.time('treeGrid');
                    // 对Ajax返回的原始数据的进行预处理
                    var dataMap = {};
                    $.each(data, function (idx, obj) {
                        obj.parentId = obj.parentId || null;
                        obj.parentName = obj.parentName || '';
                        if (dataMap[obj.parentId]) {
                            dataMap[obj.parentId].push(obj);
                        } else {
                            dataMap[obj.parentId] = [];
                            dataMap[obj.parentId].push(obj);
                        }
                    });
                    // 构建树形结构格式的表格数据
                    var dataGrid = [];
                    var rebuild = function (group) {
                        if (!group) {
                            return;
                        }
                        $.each(group, function (idx, obj) {
                            dataGrid.push(obj);
                            rebuild(dataMap[obj.id]);
                        });
                    };
                    rebuild(dataMap[null]);
                    // console.timeEnd('treeGrid');
                    return dataGrid;
                }
            },
            columns: [
                {
                    data: 'name',
                    width: '25%',
                    render: function (data, type, row) {
                        for (var i = 1, j = String(row['parentIds']).split('/').length; i < j; i++) {
                            data = '&emsp;&emsp;' + data;
                        }
                        return data;
                    }
                },
                {
                    data: 'type',
                    className: 'dt-center',
                    render: function (data, type, row) {
                        var dataMap = {
                            'MENU': '<span class="label label-primary">菜单</span>',
                            'FUNC': '<span class="label label-success">功能</span>'
                        };
                        return dataMap[data] || '';
                    }
                },
                {data: 'code'},
                {data: 'url'},
                {
                    data: 'status',
                    className: 'dt-center',
                    render: function (data, type, row) {
                        var dataMap = {
                            '0': '<span class="label label-danger">不可用</span>',
                            '1': '<span class="label label-info">可用</span>'
                        };
                        return dataMap[data] || '';
                    }
                },
                {data: 'seq', className: 'dt-right'},
                {data: 'icon', className: 'dt-center'},
                {data: 'parentName', className: 'dt-center'}
            ],
            fnInitComplete: function (settings, json) {
                $table.buttons().container().appendTo($('.col-sm-6:eq(0)', $table.table().container()));
                $table.buttons().nodes().attr({'data-toggle': 'tooltip'}).bind('click', $.noop());
            }
        }).on('click', 'tbody tr', function () {
            $table.buttons(['edit:name', 'delete:name']).enable($table.rows({selected: true}).data().length === 1);
        });

    });
</script>
</body>
</html>