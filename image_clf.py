import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt
from tensorflow.keras.layers import Conv2D, MaxPool2D, Dense, Flatten, Input
from tensorflow.keras.models import Sequential

train_dataset_path = r"C:\blood-group-through-fingerprint\Blood-Group-Detection-Through-Fingerprint\dataset\train"
test_dataset_path = r"C:\blood-group-through-fingerprint\Blood-Group-Detection-Through-Fingerprint\dataset\test"

# Initialize ImageDataGenerator for training data with augmentation
train_datagen = ImageDataGenerator(
    rescale=1./255,
    shear_range=0.2,
    zoom_range=0.2,
    horizontal_flip=True
)

# Initialize ImageDataGenerator for test data (no augmentation, only rescaling)
test_datagen = ImageDataGenerator(rescale=1./255)

# Load images from directories
train_generator = train_datagen.flow_from_directory(
    train_dataset_path,
    target_size=(32, 32),
    batch_size=32,
    class_mode='categorical'
)

test_generator = test_datagen.flow_from_directory(
    test_dataset_path,
    target_size=(32, 32),
    batch_size=32,
    class_mode='categorical'
)
cnn = Sequential()
cnn.add(Input(shape=(32, 32, 3)))
cnn.add(Conv2D(filters=32, kernel_size=(3,3), strides=(1,1), activation="relu"))
cnn.add(MaxPool2D(pool_size=(2,2), strides=2))
cnn.add(Conv2D(filters=64, kernel_size=(3,3), strides=(1,1), activation="relu"))
cnn.add(MaxPool2D(pool_size=(2,2), strides=2))
cnn.add(Flatten())
cnn.add(Dense(units=128, activation="relu"))
cnn.add(Dense(units=64, activation="relu"))
cnn.add(Dense(units=train_generator.num_classes, activation="softmax"))
cnn.compile(optimizer="adam", loss="categorical_crossentropy", 
            metrics=["accuracy"])

# Train the model using the generated and augmented data
history = cnn.fit(
    train_generator,
    epochs=5,
    validation_data=test_generator
)
# Save the trained model to a file
cnn.save('cnn_model.h5')  # Save the model in HDF5 format
print("Model saved successfully!")

# Plot training & validation accuracy values
plt.plot(history.history['accuracy'])
plt.plot(history.history['val_accuracy'])
plt.title('Model accuracy')
plt.ylabel('Accuracy')
plt.xlabel('Epoch')
plt.legend(['Train', 'Validation'], loc='upper left')
plt.show()
