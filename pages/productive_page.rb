my_productive_page = "#{ENV['HOME']}/.productive_page"
if File.exists?(my_productive_page)
  load my_productive_page
else
  page do
    set_title "Tesk Tesk Tesk"
    <<-END
      <h1 style="text-align:center; margin:0px; padding:10px; font-size:52px; background:#C00;"><script>document.write(window.location)</script> ?!</h1>
      <div style="text-align:center">
        <p style="margin:0px auto; display:block; font-size:30px; width:350px;">
          No why would you wanna go there?<br/>
          Here is something better:
          <object width="425" height="344"><param name="movie" value="http://www.youtube.com/v/NN75im_us4k&hl=en&fs=1&rel=0"></param><param name="allowFullScreen" value="true"></param><param name="allowscriptaccess" value="always"></param><embed src="http://www.youtube.com/v/NN75im_us4k&hl=en&fs=1&rel=0" type="application/x-shockwave-flash" allowscriptaccess="always" allowfullscreen="true" width="425" height="344"></embed></object>
        </p>
        <p tyle="margin:0px auto; display:block; width:350px;">
          <h2>Now GO BACK TO WORK!</h2>
        </p>
      </div>
      <hr/>
      <strong>productivity_ftw</strong> was created by <a href="http://blog.eizesus.com">Elad Meidar</a>, with the awesome <a href="http://github.com/bjeanes/ghost/">ghost</a> gem by <a href="http://bjeans.com">bjeans<a/> and the <a href="http://gist.github.com/188861">Ruby server in one gist</a> by <a href="http://gist.github.com/h0rs3r4dish">h0rs3r4dish</a> 
    
    
    END

  end
end
