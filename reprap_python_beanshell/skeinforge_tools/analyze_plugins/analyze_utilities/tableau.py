"""
Tableau has a couple of base classes for analyze viewers.

"""

from __future__ import absolute_import
#Init has to be imported first because it has code to workaround the python bug where relative imports don't work if the module is imported as a main module.
import __init__

from skeinforge_tools.skeinforge_utilities import gcodec
from skeinforge_tools.skeinforge_utilities import preferences
import os

__author__ = "Enrique Perez (perez_enrique@yahoo.com)"
__date__ = "$Date: 2008/21/04 $"
__license__ = "GPL 3.0"


class TableauPreferences:
	"A utility class to add tableau functions."
	def addToArchiveUpdate( self, archivablePreference ):
		"Add preference to the archive and the update preferences."
		self.archive.append( archivablePreference )
		self.updatePreferences.append( archivablePreference )

	def addToArchivePhoenixUpdate( self, archivablePreference ):
		"Add preference to the archive, the phoenix preferences, and the update preferences."
		self.addToArchiveUpdate( archivablePreference )
		self.phoenixPreferenceTable[ archivablePreference ] = None

	def setUpdateFunction( self, updateFunction ):
		"Set the update function of the update preferences."
		self.updateFunction = updateFunction
		for updatePreference in self.updatePreferences:
			updatePreference.setUpdateFunction( self.setToDisplaySaveUpdate )

	def setToDisplaySaveUpdate( self, event = None ):
		"Set the preference values to the display, save the new values, then call the update function."
		for updatePreference in self.updatePreferences:
			updatePreference.setToDisplay()
		preferences.writePreferences( self )
		if self.updateFunction != None:
			self.updateFunction()


class TableauWindow:
	def centerUpdateSetWindowGeometryShowPreferences( self ):
		"Center the scroll region, update, set the window geometry, and show the preferences."
		for updatePreference in self.tableauPreferences.updatePreferences:
			updatePreference.addToMenu( self.preferencesMenu )
		self.relayXview( preferences.Tkinter.MOVETO, 0.5 * ( 1.0 - float( self.canvasWidth ) / float( self.screenSize.real ) ) )
		self.relayYview( preferences.Tkinter.MOVETO, 0.5 * ( 1.0 - float( self.canvasHeight ) / float( self.screenSize.imag ) ) )
		self.update()
		geometryString = self.root.geometry()
		if geometryString == '1x1+0+0':
			self.root.update_idletasks()
			geometryString = self.root.geometry()
		firstPlusIndex = geometryString.find( '+' )
		if geometryString[ firstPlusIndex + 1 : ] != '0+0':
			geometryString = geometryString[ : firstPlusIndex + 1 ] + '0+0'
			self.root.geometry( geometryString )
			self.root.update_idletasks()
		self.tableauPreferences.setUpdateFunction( self.update  )

	def destroyAllDialogWindows( self ):
		"Destroy all the dialog windows."
		for updatePreference in self.tableauPreferences.updatePreferences:
			lowerName = updatePreference.name.lower()
			if lowerName in preferences.globalPreferencesDialogListTable:
				globalPreferencesDialogValues = preferences.globalPreferencesDialogListTable[ lowerName ]
				for globalPreferencesDialogValue in globalPreferencesDialogValues:
					preferences.quitWindow( globalPreferencesDialogValue.root )

	def destroyMovementText( self ):
		'Destroy the movement text.'
		self.canvas.delete( self.movementTextID )
		self.movementTextID = None

	def export( self ):
		"Export the canvas as a postscript file."
		postscriptFileName = gcodec.getFilePathWithUnderscoredBasename( self.skein.fileName, self.suffix )
		boundingBox = self.canvas.bbox( preferences.Tkinter.ALL ) # tuple (w, n, e, s)
		boxW = boundingBox[ 0 ]
		boxN = boundingBox[ 1 ]
		boxWidth = boundingBox[ 2 ] - boxW
		boxHeight = boundingBox[ 3 ] - boxN
		print( 'Exported postscript file saved as ' + postscriptFileName )
		self.canvas.postscript( file = postscriptFileName, height = boxHeight, width = boxWidth, pageheight = boxHeight, pagewidth = boxWidth, x = boxW, y = boxN )
		fileExtension = self.tableauPreferences.exportFileExtension.value
		postscriptProgram = self.tableauPreferences.exportPostscriptProgram.value
		if postscriptProgram == '':
			return
		postscriptFilePath = '"' + os.path.normpath( postscriptFileName ) + '"' # " to send in file name with spaces
		shellCommand = postscriptProgram + ' ' + postscriptFilePath
		print( '' )
		if fileExtension == '':
			print( 'Sending the shell command:' )
			print( shellCommand )
			commandResult = os.system( shellCommand )
			if commandResult != 0:
				print( 'It may be that the system could not find the %s program.' % postscriptProgram )
				print( 'If so, try installing the %s program or look for another one, like the Gnu Image Manipulation Program (Gimp) which can be found at:' % postscriptProgram )
				print( 'http://www.gimp.org/' )
			return
		convertedFileName = gcodec.getFilePathWithUnderscoredBasename( postscriptFilePath, '.' + fileExtension + '"' )
		shellCommand += ' ' + convertedFileName
		print( 'Sending the shell command:' )
		print( shellCommand )
		commandResult = os.system( shellCommand )
		if commandResult != 0:
			print( 'The %s program could not convert the postscript to the %s file format.' % ( postscriptProgram, fileExtension ) )
			print( 'Try installing the %s program or look for another one, like Image Magick which can be found at:' % postscriptProgram )
			print( 'http://www.imagemagick.org/script/index.php' )

	def getTagsGivenXY( self, x, y ):
		"Get the tag for the x and y."
		if self.movementTextID != None:
			self.destroyMovementText()
		tags = self.canvas.itemcget( self.canvas.find_closest( x, y ), 'tags' )
		currentEnd = ' current'
		if tags.find( currentEnd ) != - 1:
			return tags[ : - len( currentEnd ) ]
		return tags

	def relayXview( self, *args ):
		"Relay xview changes."
		self.canvas.xview( *args )

	def relayYview( self, *args ):
		"Relay yview changes."
		self.canvas.yview( *args )

	def setMenuPanesPreferencesRootSkein( self, skein, suffix, tableauPreferences ):
		"Set the menu bar, skein panes, tableau preferences, root and skein."
		self.movementTextID = None
		self.root = preferences.Tkinter.Tk()
		self.skein = skein
		self.skeinPanes = skein.skeinPanes
		self.suffix = suffix
		self.tableauPreferences = tableauPreferences
		for phoenixPreferenceTableKey in tableauPreferences.phoenixPreferenceTable.keys():
			tableauPreferences.phoenixPreferenceTable[ phoenixPreferenceTableKey ] = phoenixPreferenceTableKey.value
		self.fileHelpMenuBar = preferences.FileHelpMenuBar( self.root )
		self.fileHelpMenuBar.fileMenu.add_command( label = "Export", command = self.export )
		self.fileHelpMenuBar.fileMenu.add_separator()
