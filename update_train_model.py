import tensorflow as tf
from tensorflow.keras.preprocessing.image import ImageDataGenerator
import matplotlib.pyplot as plt

model = tf.keras.models.load_model('cnn_model.h5')

# Recompile the model with a new optimizer
model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])

# Initialize ImageDataGenerator for incorrect classification data
incorrect_classifications_path = r"C:\FYPproject\dataset\incorrect_classifications"
incorrect_data_gen = ImageDataGenerator(rescale=1./255)

incorrect_generator = incorrect_data_gen.flow_from_directory(
    incorrect_classifications_path,
    target_size=(32, 32),
    batch_size=32,
    class_mode='categorical'
)

# Fine-tune the model
history = model.fit(
    incorrect_generator,
    epochs=5,
    verbose=1
)

# Save the updated model
model.save('cnn_model_updated.h5')
print("Model updated and saved as cnn_model_updated.h5!")

plt.plot(history.history['accuracy'])
plt.title('Model Fine-tuning Accuracy')
plt.ylabel('Accuracy')
plt.xlabel('Epoch')
plt.legend(['Fine-tuning'], loc='upper left')
plt.show()
