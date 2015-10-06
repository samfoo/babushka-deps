dep 'user font dir exists' do
  met? {
    "~/Library/Fonts".p.dir?
  }
  meet {
    log_shell "Creating ~/Library/Fonts", "mkdir ~/Library/Fonts"
  }
end

meta 'font' do
  accepts_list_for :source
  accepts_list_for :extra_source
  accepts_list_for :ttf_filename

  template {
    requires 'user font dir exists'

    met? {
      "~/Library/Fonts/#{ttf_filename.first}".p.exists?
    }

    meet {
      source.each do |uri|
        Babushka::Resource.extract(uri) do
          Dir.glob("*.?tf") do |font|
            log_shell "Installing #{font}", "cp '#{font}' ~/Library/Fonts"
          end
        end
      end
    }
  }
end

dep 'inconsolata.font' do
  source 'http://www.fontsquirrel.com/fonts/download/Inconsolata'
  ttf_filename "Inconsolata.otf"
end

dep 'open-sans.font' do
  source 'http://www.fontsquirrel.com/fonts/download/open-sans'
  ttf_filename 'OpenSans-Regular.ttf'
end

dep 'all-fonts' do
  requires 'user font dir exists'
  requires 'inconsolata.font'
  requires 'open-sans.font'
  requires 'anonymous-pro.font'
end

dep 'anonymous-pro.font' do
  source 'http://www.marksimonson.com/assets/content/fonts/AnonymousPro-1.002.zip'
  ttf_filename 'Anonymous Pro.ttf'
end

