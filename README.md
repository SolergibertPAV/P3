PAV - P3: detección de pitch
============================

Esta práctica se distribuye a través del repositorio GitHub [Práctica 3](https://github.com/albino-pav/P3).

Prueba

Siga las instrucciones de la [Práctica 2](https://github.com/albino-pav/P2) para realizar un `fork` de la
misma y distribuir copias locales (*clones*) del mismo a los distintos integrantes del grupo de prácticas.

Recuerde realizar el *pull request* al repositorio original una vez completada la práctica.

Ejercicios básicos
------------------

- Complete el código de los ficheros necesarios para realizar la detección de pitch usando el programa
  `get_pitch`.

   * Complete el cálculo de la autocorrelación e inserte a continuación el código correspondiente.
  ~~~
  void PitchAnalyzer::autocorrelation(const vector<float> &x, vector<float> &r) const {

    for (unsigned int m = 0; m < r.size(); ++m) {
  		/// \TODO Compute the autocorrelation r[l]
      r[m] = 0;
      for (unsigned int n = 0; n < x.size() - m; ++n) {
          r[m] += x[n]*x[n+m];
      }
      r[m] /= x.size();
    }

    if (r[0] == 0.0F) //to avoid log() and divide zero 
      r[0] = 1e-10; 
  }
  ~~~
   * Inserte una gŕafica donde, en un *subplot*, se vea con claridad la señal temporal de un segmento de
     unos 30 ms de un fonema sonoro y su periodo de pitch; y, en otro *subplot*, se vea con claridad la
	 autocorrelación de la señal y la posición del primer máximo secundario.

   NOTA: es más que probable que tenga que usar Python, Octave/MATLAB u otro programa semejante para
	 hacerlo. Se valorará la utilización de la librería matplotlib de Python.

  ![](imagenes_p3/grafica_señal.PNG)
  ![](imagenes_p3/tramo_sonoro.PNG)
  ![](imagenes_p3/autocorrelacion.PNG)  

  El código utilizando, haciendo uso de la librería matplotlib de Python, para hacer las gráficas es el siguiente:
  ~~~
  señal, fm = sf.read('Audio.wav') 
  t = np.arange(0, len(señal)) / fm 
  plt.xlabel('s')
  plt.ylabel('Amplitud')
  plt.xlim(right = 10)
  plt.plot(t, señal)
  plt.show()
  ~~~

  ~~~
  t_ms = 30                       #Introducimos un valor de tiempo en milisegundos
  l = int((fm * t_ms)/1e3)        #Calculamos el número de muestras

  plt.plot(t[fm:fm+l], señal[fm:fm+l])
  plt.xlabel('Muestra')
  plt.ylabel('Amplitud')
  plt.show()
  ~~~

  ~~~
  def autocorrelacion(vector):
  autocorrelation = np.correlate(vector, vector, mode = 'full')
  return autocorrelation[autocorrelation.size//2:]

  plt.plot(t[:l]*1000, autocorrelacion(señal[fm:fm+l]))
  plt.show()
  ~~~

   * Determine el mejor candidato para el periodo de pitch localizando el primer máximo secundario de la
     autocorrelación. Inserte a continuación el código correspondiente.
  Función compute_pitch:
  ~~~
  float PitchAnalyzer::compute_pitch(vector<float> & x) const {
    if (x.size() != frameLen)
      return -1.0F;

    //Center clipping & Window input frame
    for (unsigned int i=0; i<x.size(); ++i){
      if(x[i] < th_clipping_p && x[i] > -th_clipping_p){
        x[i] = 0;
      }
      //cout << x[i] << '\n';
      x[i] *= window[i];
    }

    vector<float> r(npitch_max);

    //Compute correlation
    autocorrelation(x, r);
 
    //vector<float>::const_iterator iR = r.begin(), iRMax = iR + npitch_min;
    vector<float>::const_iterator iRMax = r.begin() + npitch_min;
    
    ///buscamos el valor máximo del pitch
    for (vector<float>::const_iterator iR = iRMax; iR < r.end(); iR++) {
      if(*iR > *iRMax) {
        iRMax = iR;
      }
    }
    unsigned int lag = iRMax - r.begin();

    float pot = 10 * log10(r[0]);

    //You can print these (and other) features, look at them using wavesurfer
    //Based on that, implement a rule for unvoiced
    //change to #if 1 and compile
#if 0
    if (r[0] > 0.0F)
      cout << pot << '\t' << r[1]/r[0] << '\t' << r[lag]/r[0] << endl;
#endif
    
    if (unvoiced(pot, r[1]/r[0], r[lag]/r[0]))
      return 0;
    else
      return (float) samplingFreq/(float) lag;
  }
}
  ~~~
   * Implemente la regla de decisión sonoro o sordo e inserte el código correspondiente.
   
   bool PitchAnalyzer::unvoiced(float pot, float r1norm, float rmaxnorm) const {
    /// \TODO Implement a rule to decide whether the sound is voiced or not.
    /// * You can use the standard features (pot, r1norm, rmaxnorm),
    ///   or compute and use other ones.
  ~~~  
    if (r1norm > umbral_p){///donde umbral_p es igual al valor que le damos al parámetro umbral, por defecto /////vale 0,91
      return false;
    }

    return true; //aqui habia un true
    /// \DONE
    /// Posible mejora del criterio
  }
  ~~~
- Una vez completados los puntos anteriores, dispondrá de una primera versión del detector de pitch. El 
  resto del trabajo consiste, básicamente, en obtener las mejores prestaciones posibles con él.

  * Utilice el programa `wavesurfer` para analizar las condiciones apropiadas para determinar si un
    segmento es sonoro o sordo. 
	
	  - Inserte una gráfica con la detección de pitch incorporada a `wavesurfer` y, junto a ella, los 
	    principales candidatos para determinar la sonoridad de la voz: el nivel de potencia de la señal
		(r[0]), la autocorrelación normalizada de uno (r1norm = r[1] / r[0]) y el valor de la
		autocorrelación en su máximo secundario (rmaxnorm = r[lag] / r[0]).
    ![](imagenes_p3/pitch_wavesurfer.PNG)
  
    //falta incluir todo sobre las correlaciones

		Puede considerar, también, la conveniencia de usar la tasa de cruces por cero.

	    Recuerde configurar los paneles de datos para que el desplazamiento de ventana sea el adecuado, que
		en esta práctica es de 15 ms.

    

      - Use el detector de pitch implementado en el programa `wavesurfer` en una señal de prueba y compare
	    su resultado con el obtenido por la mejor versión de su propio sistema.  Inserte una gráfica
		ilustrativa del resultado de ambos detectores.
    ![](imagenes_p3/wavesurferf0.PNG)
    ![](imagenes_p3/wavesurferf0ref.PNG)
    ![](imagenes_p3/comparacion.PNG)

    Como vemos en el terminal de la última imagen el resultado obtenido es de un 65,17%. Esta detección no es muy precisa como se puede apreciar comparando ambas gráficas de la señal rl001.
  
  * Optimice los parámetros de su sistema de detección de pitch e inserte una tabla con las tasas de error
    y el *score* TOTAL proporcionados por `pitch_evaluate` en la evaluación de la base de datos 
	`pitch_db/train`..

  ![](imagenes_p3/resultado.PNG)

   * Inserte una gráfica en la que se vea con claridad el resultado de su detector de pitch junto al del
     detector de Wavesurfer. Aunque puede usarse Wavesurfer para obtener la representación, se valorará
	 el uso de alternativas de mayor calidad (particularmente Python).
   

Ejercicios de ampliación
------------------------

- Usando la librería `docopt_cpp`, modifique el fichero `get_pitch.cpp` para incorporar los parámetros del
  detector a los argumentos de la línea de comandos.
  
  Esta técnica le resultará especialmente útil para optimizar los parámetros del detector. Recuerde que
  una parte importante de la evaluación recaerá en el resultado obtenido en la detección de pitch en la
  base de datos.

  * Inserte un *pantallazo* en el que se vea el mensaje de ayuda del programa y un ejemplo de utilización
    con los argumentos añadidos.
  ![](imagenes_p3/mensaje_de_ayuda_y_ejemplo.PNG)

- Implemente las técnicas que considere oportunas para optimizar las prestaciones del sistema de detección
  de pitch.

  Entre las posibles mejoras, puede escoger una o más de las siguientes:

  * Técnicas de preprocesado: filtrado paso bajo, *center clipping*, etc.
//Center clipping & Window input frame
  ~~~
    for (unsigned int i=0; i<x.size(); ++i){
      if(x[i] < th_clipping_p && x[i] > -th_clipping_p){
        x[i] = 0;
      }
      //cout << x[i] << '\n';
      x[i] *= window[i];
    }
  ~~~
  * Técnicas de postprocesado: filtro de mediana, *dynamic time warping*, etc.
///implementacion filtro de mediana
  ~~~
  vector<float> f0_F = f0; //Creamos un vector copia de f0 para poder extraer los valores ya que los modificaremos directamente de f0

  for(int n = 1; n < f0_F.size() - 1; n++){
    //cout << n << "\n";
    //cout << f0_F[n] << "\n";
    float arr[] = {f0_F[n-1], f0_F[n], f0_F[n+1]};
      for (int j = 0; j<3; j++){
        //cout << arr[j] << " ";
      }
    sort(arr, arr+3);
    f0[n] = arr[1];
    //cout << "\n" << f0[n] << "\n\n";
  }
  ~~~
  * Métodos alternativos a la autocorrelación: procesado cepstral, *average magnitude difference function*
    (AMDF), etc.
  * Optimización **demostrable** de los parámetros que gobiernan el detector, en concreto, de los que
    gobiernan la decisión sonoro/sordo.
  * Cualquier otra técnica que se le pueda ocurrir o encuentre en la literatura.

  Encontrará más información acerca de estas técnicas en las [Transparencias del Curso](https://atenea.upc.edu/pluginfile.php/2908770/mod_resource/content/3/2b_PS%20Techniques.pdf)
  y en [Spoken Language Processing](https://discovery.upc.edu/iii/encore/record/C__Rb1233593?lang=cat).
  También encontrará más información en los anexos del enunciado de esta práctica.

  Incluya, a continuación, una explicación de las técnicas incorporadas al detector. Se valorará la
  inclusión de gráficas, tablas, código o cualquier otra cosa que ayude a comprender el trabajo realizado.

  También se valorará la realización de un estudio de los parámetros involucrados. Por ejemplo, si se opta
  por implementar el filtro de mediana, se valorará el análisis de los resultados obtenidos en función de
  la longitud del filtro.
   

Evaluación *ciega* del detector
-------------------------------

Antes de realizar el *pull request* debe asegurarse de que su repositorio contiene los ficheros necesarios
para compilar los programas correctamente ejecutando `make release`.

Con los ejecutables construidos de esta manera, los profesores de la asignatura procederán a evaluar el
detector con la parte de test de la base de datos (desconocida para los alumnos). Una parte importante de
la nota de la práctica recaerá en el resultado de esta evaluación.
