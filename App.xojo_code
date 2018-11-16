#tag Class
Protected Class App
Inherits Application
	#tag Event
		Sub Open()
		  dim AMBInitialDate as new date
		  dim res as Boolean
		  
		  theDB = new DBSupport
		  
		  if TargetWin32 then
		    MDIWindow.MinHeight=700
		    MDIWindow.MinWidth=1100
		    MDIWindow.Maximize
		  end if
		  
		  AMBInitialDate.SQLDateTime="1970-01-01 00:00:00"
		  AMBOffset=AMBInitialDate.TotalSeconds
		  'AMBOffset=0
		  
		  PrefsRead
		  
		End Sub
	#tag EndEvent


	#tag Method, Flags = &h0
		Function ConvertSecondsToTime(Time as double, IncludeDate as boolean) As string
		  dim Fraction as double
		  dim WholeTime as new date
		  dim Hours, Minutes, Seconds, TimeString as string
		  
		  
		  
		  if IncludeDate then
		    Fraction=val(format(Time-floor(Time),".000"))
		    WholeTime.TotalSeconds=AMBOffset+Floor(Time)
		    TimeString=WholeTime.SQLDateTime+format(Fraction,".000")
		  else
		    Hours=format(Time\3600,"00")
		    Time=Time-val(Hours)*3600
		    Minutes=format(Time\60,"00")
		    Time=Time-val(Minutes)*60
		    Seconds=format(Time,"00.000")
		    TimeString=Hours+":"+Minutes+":"+Seconds
		  end if
		  
		  return TimeString
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrefsRead()
		  Dim xdoc as XmlDocument
		  Dim node as XMLNode
		  Dim i, count as Integer
		  Dim out as String
		  Dim f as FolderItem
		  f=SpecialFolder.Preferences.Child("dynamic.plist")
		  
		  if f.Exists then
		    // create a new document
		    xdoc = New XmlDocument
		    xdoc.PreserveWhitespace = False
		    
		    xdoc.LoadXml(f)
		    
		    node = xdoc.DocumentElement.Child(0)
		    
		    for i = 0 to xdoc.DocumentElement.ChildCount - 1
		      node = xdoc.DocumentElement.Child(i)
		      
		      Select case node.name
		        
		      case "UserName"
		        if node.ChildCount>0 then
		          UserName=node.FirstChild.Value
		        end if
		        
		      case "Password"
		        if node.ChildCount>0 then
		          Password = DecodeBase64(node.FirstChild.Value)
		        end if
		        
		      case "TXWriteTime"
		        if node.ChildCount>0 then
		          TxWriteTime = Val(node.FirstChild.Value)
		          If TxWriteTime > 0 Then
		            Dynamic.TXExportTimer.Period=TxWriteTime * 60000
		            Dynamic.TXExportTimer.Mode=Timer.ModeMultiple
		          Else
		            Dynamic.TXExportTimer.Mode=Timer.ModeOff
		          End If
		        end if
		        
		      case "TXWritePath"
		        if node.ChildCount>0 then
		          TXWritePath = node.FirstChild.Value
		        end if
		      end Select
		      
		    next
		    
		  end if
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub PrefsWrite()
		  Dim xml as XmlDocument
		  Dim root, UserNamePathNode, PasswordPathNode, TXWriteTimePathNode, TXWritePathPathNode as XMLNode
		  Dim f as FolderItem
		  f=SpecialFolder.Preferences.Child("dynamic.plist")
		  
		  xml = New XmlDocument
		  root = xml.AppendChild(xml.CreateElement("root"))
		  
		  UserNamePathNode = root.AppendChild(xml.CreateElement("UserName"))
		  UserNamePathNode.AppendChild(xml.CreateTextNode(UserName))
		  
		  PasswordPathNode = root.AppendChild(xml.CreateElement("Password"))
		  PasswordPathNode.AppendChild(xml.CreateTextNode(EncodeBase64(Password,0)))
		  
		  TXWriteTimePathNode = root.AppendChild(xml.CreateElement("TXWriteTime"))
		  TXWriteTimePathNode.AppendChild(xml.CreateTextNode(Str(TxWriteTime)))
		  
		  If TxWriteTime > 0 Then
		    Dynamic.TXExportTimer.Period=TxWriteTime * 60000
		    Dynamic.TXExportTimer.Mode=Timer.ModeMultiple
		  Else
		    Dynamic.TXExportTimer.Mode=Timer.ModeOff
		  End If
		  
		  TXWritePathPathNode = root.AppendChild(xml.CreateElement("TXWritePath"))
		  TXWritePathPathNode.AppendChild(xml.CreateTextNode(TXWritePath))
		  
		  xml.SaveXml(f)
		  
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		AMBOffset As double
	#tag EndProperty

	#tag Property, Flags = &h0
		CRC16Table(255) As MemoryBlock
	#tag EndProperty

	#tag Property, Flags = &h0
		IAmServer As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h0
		IPAddressFirstThree As String
	#tag EndProperty

	#tag Property, Flags = &h0
		Password As String
	#tag EndProperty

	#tag Property, Flags = &h0
		ReaderType As String = """iPico"""
	#tag EndProperty

	#tag Property, Flags = &h0
		ServerAutoDiscovery As AutoDiscovery
	#tag EndProperty

	#tag Property, Flags = &h0
		theDB As DBSupport
	#tag EndProperty

	#tag Property, Flags = &h0
		TXWritePath As String
	#tag EndProperty

	#tag Property, Flags = &h0
		TxWriteTime As Integer
	#tag EndProperty

	#tag Property, Flags = &h0
		UserName As String
	#tag EndProperty

	#tag Property, Flags = &h0
		UTCOffset As integer
	#tag EndProperty


	#tag Constant, Name = kEditClear, Type = String, Dynamic = False, Default = \"&Delete", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"&Delete"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"&Delete"
	#tag EndConstant

	#tag Constant, Name = kFileQuit, Type = String, Dynamic = False, Default = \"&Quit", Scope = Public
		#Tag Instance, Platform = Windows, Language = Default, Definition  = \"E&xit"
	#tag EndConstant

	#tag Constant, Name = kFileQuitShortcut, Type = String, Dynamic = False, Default = \"", Scope = Public
		#Tag Instance, Platform = Mac OS, Language = Default, Definition  = \"Cmd+Q"
		#Tag Instance, Platform = Linux, Language = Default, Definition  = \"Ctrl+Q"
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="ReaderType"
			Group="Behavior"
			InitialValue="""iPico"""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UTCOffset"
			Group="Behavior"
			Type="integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="AMBOffset"
			Group="Behavior"
			Type="double"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IPAddressFirstThree"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="IAmServer"
			Group="Behavior"
			InitialValue="false"
			Type="Boolean"
		#tag EndViewProperty
		#tag ViewProperty
			Name="UserName"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="Password"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TxWriteTime"
			Group="Behavior"
			Type="Integer"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TXWritePath"
			Group="Behavior"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
