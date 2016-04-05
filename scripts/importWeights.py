import numpy
import os

def toNumpyArray(fid):
	shape=[]
	l = fid.readline().split()
	for t in l:
		shape.append(int(t))
	shape.reverse()
	numElements = numpy.prod(shape)
	arr = numpy.fromfile(fid,dtype=numpy.float32,count=numElements)
	matrix = arr.reshape(shape)
	return matrix.transpose()

class Layer:
	def __init__(self):
		self.type=''
		self.actFun=''
		self.stride=0
		self.kernelSize=[]
		self.layerSize=[]
		self.w=None
		self.uw=None
		self.dw=None
		self.c=None
		self.b=None
	
	def __str__(self):
		return "<%-15s %s>" % (self.type,str(self.layerSize))

	def __repr__(self):
		return str(self)

class Model:
	def __init__(self,filename):
		f = open(filename,'rb')
		self.isGenerative = not 'discriminative' in filename
		self.layers = []
		while True:
			l = f.readline()
			if not l:
				break
			if l.startswith('numLayer'):
				self.numLayer = int(l.split()[1])
			elif l.startswith('classes'):
				self.classes = int(l.split()[1])
			elif l.startswith('validation'):
				self.validation = int(l.split()[1])
			elif l.startswith('duplicate'):
				self.duplicate = int(l.split()[1])
			elif l.startswith('volume_size'):
				self.volume_size = int(l.split()[1])
			elif l.startswith('pad_size'):
				self.pad_size = int(l.split()[1])
			elif l.startswith('layer'):
				ly = Layer()
				ly.type = f.readline().split()[1]
				for i in f.readline().split()[1:]:
					ly.layerSize.append(int(i))
				if not ly.type=='input':
					ly.actFun = f.readline().split()[1]
					if ly.type=='convolution':
						ly.stride = f.readline().split()[1]
						for i in f.readline().split()[1:]:
							ly.kernelSize.append(int(i))
					while True:
						line = f.readline()
						if line.startswith('w'):
							ly.w = toNumpyArray(f)
						elif line.startswith('uw'):
							ly.uw = toNumpyArray(f)
							ly.w = ly.uw
						elif line.startswith('dw'):
							ly.dw = toNumpyArray(f)
						elif line.startswith('c'):
							ly.c = toNumpyArray(f)
							break
					if self.isGenerative:
						if f.readline().startswith('b'):
							ly.b = toNumpyArray(f)
				self.layers.append(ly)
		f.close()

	def __str__(self):
		s = 'Model: %s %d layers %d classes\n' % ('generative' if self.isGenerative else 'discriminative',self.numLayer,self.classes)
		for l in self.layers:
			s += '\t'+str(l) + '\n'
		return s

	def __repr__(self):
		return str(self)



	
