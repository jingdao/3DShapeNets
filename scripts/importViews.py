import os
import numpy
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

def plotObject(obj):
	fig = plt.figure()
	ax = fig.add_subplot(111, projection='3d')
	x,y,z = numpy.nonzero(obj>0)
	ax.scatter(x,y,z,c='r',s=10)
	xb,yb,zb = numpy.nonzero(obj<0)
	ax.scatter(xb,yb,zb,c='b',s=1)
	plt.show()

class GridData:
	def __init__(self,filename):
		f = open(filename,'r')
		self.samples = []
		self.data_size = 30
		self.source = filename
		sample_size = self.data_size ** 3
		file_size = os.path.getsize(filename)
		self.num_samples = file_size / sample_size
		for i in range(self.num_samples):
			arr = numpy.fromfile(f,dtype=numpy.int8,count=sample_size)
			matrix = arr.reshape((self.data_size,self.data_size,self.data_size))
			self.samples.append(matrix.transpose())
	
	def __str__(self):
		return "<%s %d samples (%dx%dx%d)>" % (self.source,self.num_samples,self.data_size,self.data_size,self.data_size)

	def __repr__(self):
		return str(self)

if __name__=="__main__":
	partial_view_file = 'partial_view.data'
	complete_view_file = 'complete_view.data'

	partial_views = GridData(partial_view_file)
	complete_views = GridData(complete_view_file)
	print(partial_views)
	print(complete_views)

	for i in range(partial_views.num_samples):
		plotObject(partial_views.samples[i])
		plotObject(complete_views.samples[i])