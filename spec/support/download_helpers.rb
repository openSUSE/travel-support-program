# encoding: utf-8

#
# Helpers for downloading the files within Capybara Selenium
#
module DownloadHelpers
  # Lists all the files within the downloads directory
  def downloads
    Dir[Rails.root.join('tmp/downloads/*')]
  end

  # Returns the first download within the downloads directory
  def download
    downloads.first
  end

  # Returns a downloaded file object when it finishes downloading
  def download_file
    wait_for_download
    File.open(download)
  end

  # Waits for a download to finish
  def wait_for_download
    Timeout.timeout(10) do
      sleep 0.1 until downloaded?
    end
  end

  # Check if the file is downloaded
  def downloaded?
    !downloading? && downloads.any?
  end

  # Check if a file is downloading
  def downloading?
    downloads.grep(/\.crdownload$/).any?
  end

  # Clears the entire downloads directory
  def clear_downloads
    FileUtils.rm_f(downloads)
  end
end
