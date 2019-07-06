<%@ Control Language="vb" AutoEventWireup="false" CodeBehind="AddPhoto.ascx.vb" Inherits="Ventrian.SimpleGallery.AddPhoto" %>
<%@ Register TagPrefix="dnn" TagName="Label" Src="~/controls/LabelControl.ascx" %>
<%@ Register TagPrefix="SimpleGallery" TagName="GalleryMenu" Src="Controls\GalleryMenu.ascx" %>
<%@ Register TagPrefix="SimpleGallery" TagName="EditPhotos" Src="Controls\EditPhotos.ascx" %>
<SimpleGallery:GalleryMenu ID="ucGalleryMenu" runat="server" ShowCommandBar="False" ShowSeparator="True" />



<%--<asp:PlaceHolder ID="imageToolsScripts" runat="server" EnableViewState="False" />--%>
<asp:PlaceHolder ID="exifScripts" runat="server" EnableViewState="False" />

<style>
    .flex-container {
        display: flex;
        flex-wrap: wrap;
    }
</style>

<script runat="server">

    Sub AttachCustomHeader(ByVal CustomHeader As String)
        Dim HtmlHead As HtmlHead = Page.FindControl("Head")
        If Not (HtmlHead Is Nothing) Then
            HtmlHead.Controls.Add(New LiteralControl(CustomHeader))
        End If
    End Sub
</script>

<script type="text/javascript" src='<%= ResolveUrl("JS/compress.js") %>'></script>

<script type="text/javascript" src="//cdn.jsdelivr.net/npm/gasparesganga-jquery-loading-overlay@2.1.6/dist/loadingoverlay.min.js"></script>
<%--<script type="text/javascript" src="//cdn.jsdelivr.net/gh/brbjr1/cdn/js/201804170900/loadingoverlay_progress.js"></script>--%>

<script language="javascript" type="text/javascript">
    const compress = new Compress()

    function addElement(parentId, elementTag, elementId, html) {
        // Adds an element to the document
        var p = document.getElementById(parentId);
        var newElement = document.createElement(elementTag);
        newElement.setAttribute('id', elementId);
        newElement.innerHTML = html;
        p.appendChild(newElement);
    }

    var selected = [];

    function loadpreview() {
        $.LoadingOverlay("show");
        $('#pdiv').html('');
        //selected = [];

        var files = $('#<%=fupFile.ClientID %>')[0].files;
        var fileListAsArray = Array.from(files)
        for (var i = fileListAsArray.length - 1; i >= 0; i--)
        {
            if (fileListAsArray[i].type !== "image/jpg"
                && fileListAsArray[i].type !== "image/jpeg"
            && fileListAsArray[i].type !== "image/png"
            && fileListAsArray[i].type !== "image/gif")
            {
                fileListAsArray.splice(i,1);
            }
        }

        compress.compress(fileListAsArray, {
            size: 2, // the max size in MB, defaults to 2MB
            quality: .75, // the quality of the image, max is 1,
            maxWidth: 1024, // the max width of the output image, defaults to 1920px
            maxHeight: 768, // the max height of the output image, defaults to 1920px
            resize: true, // defaults to true, set false if you do not want to resize the image width and height
        }).then((conversions) => {

           var fu = document.getElementById('<%=fupFile.ClientID %>');
            if (fu != null) {
                document.getElementById('<%=fupFile.ClientID %>').outerHTML = fu.outerHTML;
            }

            for (var i = 0; i < conversions.length; i++) {
                selected.push(conversions[i]);
            }
            for (var i = 0; i < selected.length; i++) {

                const output = selected[i];
                addElement('pdiv', 'span', 'simage' + i, '<img style="max-width: 120px;max-height: 120px;" alt="" data-sindex="'+i+'" id="image' + i + '" src="' + output.prefix + output.data + '">');
                
            }
            HideSpinner();
        })
    }

    function ShowSpinner()
    {
        $.LoadingOverlay("show", {image: "",progress: true});
    }

    function HideSpinner()
    {
        $.LoadingOverlay('hide', true);
    }

    function StartUpload()
    {
        if (selected.length > 0)
        {
            ShowSpinner();return UploadFiles(0, Math.round(100 / selected.length));
        }
        else
        {
            alert('Plese select files to upload!');
        }
        return false;
    }

    
    function UploadFiles(lastpercent, percentcunk)
    {
        var data = new FormData();
        var newpercent = lastpercent + percentcunk;
		if (newpercent > 100)
		{
			newpercent = 100;
		}

        if (selected.length > 0)
        {
            $.LoadingOverlay("progress", newpercent);

            var myphoto = selected.pop();
            data.append("FileName", myphoto.alt);
            data.append("ContentType", myphoto.ext);
            data.append("Fdata", myphoto.data);
            data.append("AlbumID", '<%= Request("AlbumID") %>');
            data.append("TabID", '<%= Request("TabID") %>');
            data.append("ModuleID", '<%=Me.ModuleID%>');
            data.append("BatchID", '<%=Me.litBatchID.Value%>');

            $.ajax({
                type: "POST",
                url: "<%= GetUploadUrl() %>",
                contentType: false,
                processData: false,
                data: data,
                success: function (serverData) {
                    console.log(serverData);

                    if (serverData == "" || serverData == "-1" || serverData == "-2" || serverData == "-3") {
                        switch (serverData) {
                            case "":
                                alert("An error has occurred. Please see the administrator event log.");
                                break;

                            case "-1":
                                alert("An error has occurred. File limit exceeded on portal.");
                                break;

                            case "-2":
                                alert("An error has occurred. Unable to authenticate.");
                                break;

                            case "-3":
                                alert("An error has occurred. Please see the administrator event log.");
                                break;
                        }
                    }

                    if (selected.length > 0) 
                    {
                        UploadFiles(newpercent, percentcunk);
                    }
                    else
                    {
                        //HideSpinner();
                        console.log('Upload completed.');
                        document.getElementById("<%=cmdNext2.ClientID %>").click();
                    }
                }
            });
        }
        return false;
    }
</script>


<div align="left">
    <table cellspacing="0" cellpadding="0" width="600" summary="Wizard Design Table">
        <tr>
            <td width="50" height="50" align="center" valign="middle">
                <asp:Image ID="imgStep" runat="server" ImageUrl="~/DesktopModules/SimpleGallery/Images/iconStep1.gif" Width="48" Height="48" />
            </td>
            <td>
                <asp:Label ID="lblStep" runat="server" CssClass="NormalBold" /><br />
                <asp:Label ID="lblStepDescription" runat="server" CssClass="Normal" /><br />
                <asp:Label ID="lblRequiresApproval" runat="server" CssClass="NormalRed" ResourceKey="RequiresApproval" EnableViewState="False" Visible="False" />
            </td>
        </tr>
    </table>
</div>
<hr size="1" />

<asp:Panel ID="pnlStep1" runat="server">
    <asp:PlaceHolder ID="phStep1a" runat="server">
        <table cellspacing="0" cellpadding="2" width="600" summary="Select Album Design Table" align="center">
            <tr>
                <td colspan="2">
                    <asp:RadioButton ID="rdoSelectExisting" runat="server" Text="Selecting Existing Album" ResourceKey="SelectExisting" CssClass="NormalBold" GroupName="Step1" /></td>
            </tr>
            <tr valign="top">
                <td class="SubHead" width="150">
                    <dnn:Label ID="plAlbum" runat="server" ControlName="drpAlbums" Suffix=":"></dnn:Label>
                </td>
                <td>
                    <asp:DropDownList ID="drpAlbums" runat="server" DataTextField="CaptionIndented" DataValueField="AlbumID" Width="300px" />
                    <asp:CustomValidator ID="valSelectExisting" runat="server" CssClass="NormalRed" ResourceKey="valSelectExisting" Display="Dynamic"
                        ControlToValidate="drpAlbums" ErrorMessage="<br>You must select an existing album."></asp:CustomValidator>
                </td>
            </tr>
        </table>
        <hr size="1" />
    </asp:PlaceHolder>
    <asp:PlaceHolder ID="phStep1b" runat="server">
        <table cellspacing="0" cellpadding="2" width="600" summary="Select Album Design Table" align="center">
            <tr>
                <td colspan="2">
                    <asp:RadioButton ID="rdoCreateNew" runat="server" Text="Create New Album" ResourceKey="CreateNew" CssClass="NormalBold" GroupName="Step1" /></td>
            </tr>
            <tr valign="top" runat="server" id="trParentAlbum">
                <td class="SubHead" width="150">
                    <dnn:Label ID="plParentAlbum" runat="server" ResourceKey="ParentAlbum" Suffix=":" ControlName="drpParentAlbum"></dnn:Label>
                </td>
                <td>
                    <asp:DropDownList ID="drpParentAlbum" DataValueField="AlbumID" DataTextField="CaptionIndented" runat="server" Width="300px"></asp:DropDownList></td>
            </tr>
            <tr valign="top">
                <td class="SubHead" nowrap="nowrap" width="150">
                    <dnn:Label ID="plCaption" runat="server" ResourceKey="Caption" Suffix=":" ControlName="txtCaption"></dnn:Label>
                </td>
                <td align="left" width="450">
                    <asp:TextBox ID="txtCaption" CssClass="NormalTextBox" runat="server" Width="300" MaxLength="255"></asp:TextBox>
                    <asp:CustomValidator ID="valSelectNew" runat="server" CssClass="NormalRed" ResourceKey="valSelectNew" Display="Dynamic"
                        ErrorMessage="<br>You Must Enter a Valid Caption" ControlToValidate="txtCaption" ValidateEmptyText="true" />
                </td>
            </tr>
            <tr valign="top">
                <td class="SubHead" width="150">
                    <dnn:Label ID="plDescription" runat="server" Suffix=":" ControlName="txtDescription"></dnn:Label>
                </td>
                <td>
                    <asp:TextBox ID="txtDescription" CssClass="NormalTextBox" runat="server" Width="300" Columns="30"
                        MaxLength="255" TextMode="MultiLine" Rows="5"></asp:TextBox></td>
            </tr>
        </table>
    </asp:PlaceHolder>
</asp:Panel>
<asp:Panel ID="pnlStep2" runat="server">
    <asp:HiddenField ID="litBatchID" runat="server" />
    <div>
        <asp:FileUpload ID="fupFile" runat="server" AllowMultiple="true" accept=".jpg, .jpeg, .png, .gif" ClientIDMode="Static" onchange="loadpreview()" />
        <asp:RegularExpressionValidator ID="rexp" runat="server" ControlToValidate="fupFile"
            ErrorMessage="Only .gif, .jpg, .png and .jpeg"
            ValidationExpression="(.*\.([Gg][Ii][Ff])|.*\.([Jj][Pp][Gg])|.*\.([pP][nN][gG])$)">

        </asp:RegularExpressionValidator>
        <asp:Button runat="server" ID="btnUploadFiles"
            UseSubmitBehaviour="false" OnClick="btnUploadFiles_OnClick" resourcekey="btnUploadFiles" Visible="False" />

        <asp:Button runat="server" ID="Button1" OnClientClick="ShowSpinner();return UploadFiles(0);" UseSubmitBehaviour="false" resourcekey="btnUploadFiles" Visible="False" />

        <div style="margin-top: 20px;" id="pdiv" />
      
    </div>
    <br />
    <br />
    <div class="flex-container">
        <asp:Repeater runat="server" ID="addedPhotosRepeater" EnableViewState="True" OnItemDataBound="addedPhotosRepeater_OnItemDataBound" OnItemCommand="addedPhotosRepeater_ItemCommand">
            <ItemTemplate>
                <table class="photo-frame">
                    <tbody>
                        <tr>
                            <td class="topx--"></td>
                            <td class="top-x-"></td>
                            <td class="top--x"></td>
                        </tr>
                        <tr>
                            <td class="midx--"></td>
                            <td valign="top">
                                <asp:Image runat="server" ID="addedPhoto" CssClass="photo_198" />
                                <span style="align-content: center">
                                    <asp:LinkButton ID="cmdrotate" runat="server" CssClass="CommandButton" Text="Rotate" BorderStyle="none" CausesValidation="false"></asp:LinkButton>
                                </span>
                            </td>
                            <td class="mid--x"></td>
                        </tr>
                        <tr>
                            <td class="botx--"></td>
                            <td class="bot-x-"></td>
                            <td class="bot--x"></td>
                        </tr>
                    </tbody>
                </table>
            </ItemTemplate>
        </asp:Repeater>
    </div>
</asp:Panel>

<div style="width: 100%;">
    <SimpleGallery:EditPhotos ID="ucEditPhotos" runat="server" />
</div>

<asp:Panel ID="pnlWizard" runat="server">
    <div align="center">
        <br />

        

        <asp:ImageButton ID="imgPrevious" runat="server" ImageUrl="~\images\lt.gif" ImageAlign="AbsBottom" />
        <asp:LinkButton ID="cmdPrevious" resourcekey="PreviousStep" runat="server" CssClass="CommandButton" Text="Previous"
            BorderStyle="none" />
        <asp:ImageButton ID="imgCancel" runat="server" ImageUrl="~\DesktopModules\SimpleGallery\images\iconCancel.gif" ImageAlign="AbsBottom" CausesValidation="False" Style="padding-left: 20px;" />
        <asp:LinkButton ID="cmdCancel" runat="server" CssClass="CommandButton" ResourceKey="cmdCancel" Text="Cancel" BorderStyle="none" CausesValidation="False" Style="padding-right: 20px;" />
        
        <% If pnlStep2.Visible = True Then%>
             <asp:LinkButton ID="LinkButton1" OnClientClick="StartUpload(); return false;" UseSubmitBehaviour="false" resourcekey="NextStep" runat="server" CssClass="CommandButton" Text="Next" BorderStyle="none" />
             <asp:ImageButton ID="ImageButton1" OnClientClick="StartUpload(); return false;" UseSubmitBehaviour="false" runat="server" ImageUrl="~\images\rt.gif" ImageAlign="AbsBottom" />
            <span style="display:none"><asp:Button ID="cmdNext2" runat="server" Text="Next2" /></span>
           <% Else %>  
            <asp:LinkButton ID="cmdNext" resourcekey="NextStep" runat="server" CssClass="CommandButton" Text="Next" BorderStyle="none" />
            <asp:ImageButton ID="imgNext" runat="server" ImageUrl="~\images\rt.gif" ImageAlign="AbsBottom" />
          <% End If %>
    </div>
</asp:Panel>

<asp:Panel ID="pnlSave" runat="server">
    <p align="center">
        <br />
        <asp:ImageButton ID="imgSave" runat="server" ImageUrl="~\DesktopModules\SimpleGallery\images\iconSave.gif" ImageAlign="AbsBottom" />
        <asp:LinkButton ID="cmdSave" runat="server" CssClass="CommandButton" ResourceKey="cmdSave" Text="Save this batch" BorderStyle="none" />
    </p>
</asp:Panel>


<ul id="thumbnails" class="sg_photolist"></ul>
